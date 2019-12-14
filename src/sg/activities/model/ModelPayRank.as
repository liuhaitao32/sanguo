package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.net.NetMethodCfg;
    import sg.model.ModelOfficial;
    import sg.utils.ObjectUtil;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.utils.ArrayUtil;
    import sg.model.ModelUser;
    import sg.manager.ViewManager;

    public class ModelPayRank extends ViewModelBase
    {
        public static const CLOSE_PANEL:String = 'close_panel'; // 关闭面板

		// 单例
		private static var sModel:ModelPayRank = null;
		
		public static function get instance():ModelPayRank
		{
			return sModel ||= new ModelPayRank();
		}
		
        public var cfg:Object;
        public var rank:int = 0;
        public var point:int = 0;
        public var open_day:int = 0; // 活动ID
        public var _endTime:int = 0;
        public var next_open_day:int = 0;
        public var next_open_day_id:int = 0; // 下次活动ID
        public var _nextStartTime:int = 0;
        public var status:int; // 0:进行中， 1:活动结束
        public var data:Object;
        public var rankDataArr:Array;
        public var rank_reward:Boolean;
        public var point_reward:Array = [];
        public var round_dict:Object;
        private var isPuehedStart:Boolean; // 是否推送过开始消息
        public function ModelPayRank()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['pay_rank'];
            haveConfig = Boolean(cfg);
			ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_PAY_RANK, this, this.updateRankData);
        }

        override public function refreshData(data:*):void {
            if (!haveConfig) return;
            if (data && data.open_day === open_day) { // 检测玩家数据是否有效
                point_reward = data.point_reward;
                rank_reward = data.rank_reward;
            }

            // 检查推送开始消息
            var currentTime:int = ConfigServer.getServerTimer();
            round_dict = ArrayUtil.find(cfg.round, function(obj:Object):Boolean {
                return obj.open_day === open_day;
            }, this);
            if (active && _endTime && currentTime < _endTime) { // 活动进行中
                isPuehedStart || this._sendChatStartMsg(); // 只推一次
            }
            rankDataArr && rankDataArr.forEach(function(obj:Object, index:int):void { 
                obj.rank = index + 1;
                obj.gift_dict = this._getGiftDictByRank(obj.rank);
                if (obj.uid == ModelManager.instance.modelUser.mUID) { // 刷新自己的数据
                    point = obj.point;
                    rank = obj.rank;
                }
            }, this);
            // 倒计时根据活动进度推送消息
            this._refreshMsgTimer();
            this.event(ModelActivities.UPDATE_DATA);
        }
        
		private function _refreshMsgTimer():void {
            var currentTime:int = ConfigServer.getServerTimer();
            var end_show_time:int = _endTime + cfg.end_show_time * Tools.oneMinuteMilli;
            _endTime > currentTime && Laya.timer.once(_endTime - currentTime, this, this._sendChatEndMsg); // 推送结束消息
            end_show_time > currentTime && Laya.timer.once(end_show_time - currentTime, this, this._sendCloseEvent); // 发送关闭面板事件

            var show_talk:Array = cfg.show_talk;
            // 找出最近的推送时间 检查对话倒计时
            var talkTime:int = _endTime;
            var talkData:Object = null;
            var len:int = show_talk.length;
            for(var i:int = 0; i < len; i++) {
                var obj:Object = show_talk[i];
                var tempTime:int =  _endTime - obj.time * Tools.oneMinuteMilli;
                if (tempTime > currentTime && tempTime < talkTime) {
                    talkTime = tempTime;
                    talkData = obj.talk;
                }
            }
            if (talkTime !== _endTime) {
                Laya.timer.once(talkTime - currentTime, this, this._showTalk, [talkData]); // 发送关闭面板事件
            }
        }
        
		private function _showTalk(data:Array):void {
            ViewManager.instance.showHeroTalk([data], Handler.create(this, this._refreshMsgTimer));
        }

		public function updateRankData(rankData:Object):void {
            if (!haveConfig || !rankData) return;
            var user:ModelUser = ModelManager.instance.modelUser;
            var gameDate:int = user.getGameDate();
            var season_num:int = rankData.season_num || rankData.open_day - 1;
            if (rankData && (season_num + 1) === gameDate) { // 有数据
                open_day = rankData.open_day;
                data = rankData.data;
                status = rankData.status;
                _endTime = Tools.getTodayMillWithHourAndMinute(cfg.end_time);
                next_open_day = _nextStartTime = 0;
            }
            else {
                this._checkNextAct(gameDate); // 检测下次活动
            }
            
            if (data) {
                var uids:Array = ObjectUtil.keys(data);
                this.sendMethod('w.get_user_list', {uids: uids}, Handler.create(this, this.reveive_user_list));
            }
        }
        
		public function reveive_user_list(np:NetPackage):void {
            rankDataArr = np.receiveData.map(function(arr:Array):Object {
                var uid:String = arr[0];
                return {
                    rank: 0,
                    uid: uid,
                    name: arr[1],
                    pic: arr[2],
                    point: data[uid][0],
                    time: data[uid][1]
                };
            }, this);
            rankDataArr.sort(function(a:Object, b:Object):int {
                if (b.point !== a.point) {
                    return b.point - a.point;
                }
                return a.time - b.time;
            });
            this.refreshData(ModelManager.instance.modelUser.records.pay_rank_gift);
        }

        private function _checkNextAct(curr_day:int):void {
            var user:ModelUser = ModelManager.instance.modelUser;
            var serverStartTime:int = user.gameServerStartTimer;
            var serverTime:int = ConfigServer.getServerTimer();
            var len:int = cfg.round.length;
            var open_day_date:int = 0;
            var open_day_id_date:int = 0;
            for(var i:int = 0; i < len; i++) {
                var data:Object = cfg.round[i];
                var day:int = data.open_day;
                var on_date:int = data.on_date;
                var mod_day:Array = data.mod_day;
                if (curr_day > day && on_date && mod_day && open_day_id_date === 0) { // 该期为特殊活动
                    var start_time:int = Tools.getTimeStamp(on_date) + ConfigServer.system_simple.deviation * Tools.oneMinuteMilli;
                    var endTime:int = start_time + mod_day[0] * Tools.oneDayMilli;
                    if (serverTime < endTime) {
                        var start_day:int = user.getGameDate(start_time + 1);
                        var temp_open_day:int = Math.floor(start_day / mod_day[0]) * mod_day[0] + mod_day[1];
                        if (temp_open_day > curr_day) { // 没开过
                            open_day_date = temp_open_day;
                            open_day_id_date = day;
                            break;
                        }
                    }
                } else if (day > curr_day) {
                    next_open_day = next_open_day_id = day;
                }
            }
            if (open_day_id_date) {
                next_open_day = open_day_date;
                next_open_day_id = open_day_id_date;
            }
            // 存在下一个活动，开启定时器
            if (next_open_day) {
                _nextStartTime = serverStartTime + (next_open_day - 1) * Tools.oneDayMilli;
                // 检查定时器
                this._checkTimer();
            }
        }

        private function _checkTimer():void {
            var currentTime:int = ConfigServer.getServerTimer();
            var startDuration:int = _nextStartTime - currentTime;
            if (startDuration > cfg.show_time * Tools.oneMinuteMilli) {
                // 倒计时开启入口
                Laya.timer.once(startDuration - cfg.show_time * Tools.oneMinuteMilli, this, this._showEntrance);
            }
            if (startDuration > cfg.notice[0] * Tools.oneMillis) {
                // 倒计时推送即将开始
                Laya.timer.once(startDuration - cfg.notice[0] * Tools.oneMillis, this, this._pushWillStartMsg, [cfg.notice[1]]);
            }
        }

        private function _showEntrance():void {
            ModelActivities.instance.refreshLeftList();
        }

        private function _pushWillStartMsg(msgId:String):void {
            ViewManager.instance.showTipsTxt(Tools.getMsgById(msgId));
        }

        private function _sendChatStartMsg():void {
            var chatStr:String = Tools.getMsgById(cfg.start_word);
            ModelManager.instance.modelChat.sendLocalTxt(chatStr);
            this.isPuehedStart = true;
        }

        private function _sendChatEndMsg():void {
            this.getPayInfo(Handler.create(this, function():void {
                rankDataArr[0] && ModelManager.instance.modelChat.sendLocalTxt(Tools.getMsgById(cfg.end_word, [rankDataArr[0].name]));
                this.event(ModelActivities.UPDATE_DATA);
            }));
        }

        private function _sendCloseEvent():void {
            this.event(ModelActivities.UPDATE_DATA);
            this.event(ModelPayRank.CLOSE_PANEL);
            ModelActivities.instance.refreshLeftList();
        }

        private function _getGiftDictByRank(rank:int):Object {
            var max:int = cfg.split_arr[cfg.split_arr.length - 1];
            for (var i:int = rank; i <= max; ++i) {
                if (!round_dict)    return null;
                var obj:Object = round_dict.rank_reward[i];
                if (obj) {
                    return obj;
                }
            }
            return null;
        }
        
		public function getPayInfo(cb:Handler = null):void {
            this.sendMethod(NetMethodCfg.WS_SR_GET_PAY_INFO, null, Handler.create(this, function(np:NetPackage):void {
                this.updateRankData(np.receiveData);
                cb && cb.run();
            }));
        }
        
		public function refreshRank():void {
            this.sendMethod(NetMethodCfg.WS_SR_GET_PAY_INFO);
        }
        
		public function getRankReward():void {
            this.sendMethod(NetMethodCfg.WS_SR_GET_PAY_RANK_REWARD);
        }
        
		public function getPointReward(key:int):void {
            this.sendMethod(NetMethodCfg.WS_SR_GET_PAY_POINT_REWARD, {key: String(key)});
        }
        
		public function get pointRewardData():Array {
            var pointReward:Object = round_dict.point_reward
            var keys:Array = ObjectUtil.keys(pointReward); // 获取奖励档位
            keys.sort(function(a:String, b:String):int { return parseInt(a) - parseInt(b); }); // 从小到大排序
            return keys.map(function(key:String, index:int):Object {
                var goal:int = parseInt(key); 
                return {
                    goal: goal,
                    start: index > 0 ? parseInt(keys[index - 1]) : 0,
                    reward: pointReward[key],
                    state: point < goal ? 0 : (point_reward.indexOf(key) === -1 ? 1 : 2) // 1 可领取， 2 已领完
                };
            }, this);
        }
        
		public function get canPop():Boolean {
            return active && round_dict;
        }

		override public function get active():Boolean {
            if (!haveConfig || !ModelManager.instance.modelUser.canPay)    return false; // 没有活动或不支持充值
            var currentTime:int = ConfigServer.getServerTimer();
            if (_nextStartTime > 0 && currentTime > (_nextStartTime - cfg.show_time * Tools.oneMinuteMilli)) {
                return true;
            }
            if (!round_dict) {
                return false;
            }
            var end_show_time:int = _endTime + cfg.end_show_time * Tools.oneMinuteMilli;
            return currentTime < end_show_time;
        }
        
		public function get notStart():Boolean {
            var currentTime:int = ConfigServer.getServerTimer();
            return _nextStartTime && currentTime < _nextStartTime;
        }
        
		public function haveRankReward():Boolean {
            var currentTime:int = ConfigServer.getServerTimer();
            return !rank_reward && currentTime > _endTime && rank <= cfg.split_arr[cfg.split_arr.length - 1] && point;
        }
        
		public function havePointReward():Boolean {
            return pointRewardData.some(function(obj:Object):Boolean { return obj.state === 1; }, this);
        }
        
		override public function get redPoint():Boolean {
            return active && (next_open_day === 0) && round_dict && (this.haveRankReward() || this.havePointReward());
        }

        /**
         * 获取活动剩余时间
         */
        public function getTime():int {
            var currentTime:int = ConfigServer.getServerTimer();
            if (_endTime) {
                if (currentTime < _endTime) {
                    return _endTime - currentTime;
                }
                return Tools.getMsgById('550047') as Number;
            } else if (currentTime < _nextStartTime) {
                return _nextStartTime - currentTime;
            }
            return 0;
        }
    }
}