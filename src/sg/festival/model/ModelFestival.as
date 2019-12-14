package sg.festival.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;
    import sg.utils.Tools;
    import sg.net.NetSocket;
    import laya.utils.Handler;
    import sg.manager.ViewManager;
    import sg.net.NetPackage;
    import sg.model.ModelUser;
    import sg.utils.ObjectUtil;
    import sg.net.NetMethodCfg;
    import sg.activities.model.ModelActivities;
    import sg.model.ModelClimb;
    import sg.boundFor.GotoManager;

    public class ModelFestival extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelFestival = null;

        public static const UPDATE_DATA:String = 'update_data';         // 根据数据刷新界面
        public static const CLOSE_ENTRANCE:String = 'close_entrance';   // 关闭入口
		
		public static const TYPE_LOGIN:String       = 'login';      // 节日登陆
		public static const TYPE_ONCE:String        = 'once';       // 节日登陆
		public static const TYPE_ADD_UP:String      = 'add_up';     // 累计充值
		public static const TYPE_PIT_UP:String      = 'pit_up';     // 每日累充
		public static const TYPE_LUCK_SHOP:String   = 'luckshop';   // 幸运商店
		public static const TYPE_EXCHANGE:String    = 'exchange';   // 兑换商店

		public static function get instance():ModelFestival {
			return sModel ||= new ModelFestival();
		}
		
        private var _id:String = null;
        private var modelLogin:ModelFestivalLogin;
        private var modelOnce:ModelFestivalOnce;
        private var modelAddUp:ModelFestivalAddUp;
        private var modelPitUp:ModelFestivalPitUp;
        private var modelLuckShop:ModelFestivalLuckShop;
        private var modelExchange:ModelFestivalExchange;
        public var startTime:Number = 0;
        public var endTime:Number = 0;
        public var startDay:Number = 0;
        public var endDay:Number = 0;
        public var actCfg:Object = null;
        public var pf_visible:Boolean = true;
        public function ModelFestival() {
        }

        public function initModel():void {
            modelLogin = ModelFestivalLogin.instance;
            modelOnce = ModelFestivalOnce.instance;
            modelAddUp = ModelFestivalAddUp.instance;
            modelPitUp = ModelFestivalPitUp.instance;
            modelLuckShop = ModelFestivalLuckShop.instance;
            modelExchange = ModelFestivalExchange.instance;
            pf_visible = Tools.checkVisibleByPF(ConfigServer.system_simple.pf_festival);            
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var festival:Object = modelUser.records.festival;
            var id:String = '';
            if (festival) id = festival.f_key;
            if (id && this._checkId(id)) {
                this.refreshData(festival);
            }
            else    this._checkNextAct();
        }

        /**
         * 检测下次活动开启时间
         */
        private function _checkNextAct():void {
            var cfg:Object = ConfigServer.festival; // 获取配置
            if (!cfg)   return;
            var ids:Array = ObjectUtil.keys(ConfigServer.festival);
            
            // 最近的开始时间
            var nearest_start_time:Number = 0;
            var current_time:Number = ConfigServer.getServerTimer();

            for(var i:int = 0, len:int = ids.length; i < len; i++) {
                var id:String = ids[i];
                var data:Object = cfg[id];
                var start_time:Number = Tools.getTimeStamp(data.start_time);
                var end_time:Number = Tools.getTimeStamp(data.end_time);
                if (current_time < start_time) { // 这个活动还未开始
                    if (!nearest_start_time || nearest_start_time < start_time) {
                        nearest_start_time = start_time; // 更新活动开启时间
                        var timeOffset:Number = nearest_start_time - current_time;
                        if (timeOffset > 0 && timeOffset < Tools.oneDayMilli) {
                            Laya.timer.clear(this, this.notifyServer);
                            Laya.timer.once(timeOffset, this, this.notifyServer); // 通知服务器更新活动数据
                        }
                    }
                }
                else if (current_time < end_time) { // 这个活动正在进行 通知服务器更新活动数据
                    this.notifyServer();
                    return;
                }
                else { // 这个活动已过期

                }
            }
        }

        public function notifyServer():void {
            this.sendMethod(NetMethodCfg.WS_SR_GET_RECORDS);
        }

        private function _checkId(id:String):Boolean {
            var cfg:Object = ConfigServer.festival; // 获取配置
            var data:Object = cfg[id];
            var start_time:Number = Tools.getTimeStamp(data.start_time);
            var end_time:Number = Tools.getTimeStamp(data.end_time);
            var current_time:Number = ConfigServer.getServerTimer();
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            if (current_time >= start_time && current_time < end_time) {
                _id = id;
                startTime = start_time;
                endTime = end_time;
                startDay = modelUser.getGameDate(startTime + 1); // 因为偏移值时间算上一天，所以加了1毫秒
                endDay = modelUser.getGameDate(endTime);

                // 活动结束时关闭入口
                Laya.timer.clear(this, this._closeEntrance);
                Laya.timer.once(endTime - current_time, this, this._closeEntrance); // 关闭入口
                return true;
            }
            else {
                _id = null;
                startDay = startTime = 0;
                endDay = endTime = 0;
                return false;
            }
        }

        private function _closeEntrance():void {
            this.event(CLOSE_ENTRANCE);
            this.notifyServer(); // 通知服务器刷新数据
            ModelClimb.updateAllClip();
        }

        /**
         * 更新数据
         */
        override public function refreshData(festival:*):void {
            var id:String = festival.f_key;
            if (!id || !this._checkId(id)) return;
            
            // 刷新各个model的配置数据
            this.actCfg = ConfigServer.festival[id]; // 获取配置
            var actOrder:Array = actCfg.act_order;
            if (actOrder.indexOf(TYPE_LOGIN) !== -1 && actCfg.act[TYPE_LOGIN]) {
                modelLogin.initCfg(); 
                modelLogin.checkData(festival.login_time, festival.login_day);
            }
            if (actOrder.indexOf(TYPE_ONCE) !== -1 && actCfg.act[TYPE_ONCE]) {
                modelOnce.initCfg(); 
                modelOnce.checkData(festival.once_pay);
            }
            if (actOrder.indexOf(TYPE_ADD_UP) !== -1 && actCfg.act[TYPE_ADD_UP]) {
                modelAddUp.initCfg();
                modelAddUp.checkData(festival.add_up_big, festival.add_up_loop, festival.add_up_pay, festival.add_up_reward);
            }
            if (actOrder.indexOf(TYPE_PIT_UP) !== -1 && actCfg.act[TYPE_PIT_UP]) {
                modelPitUp.initCfg();
                modelPitUp.checkData(festival.pit_up_index, festival.pit_up_pay);
            }
            if (actOrder.indexOf(TYPE_LUCK_SHOP) !== -1 && actCfg.act[TYPE_LUCK_SHOP]) {
                modelLuckShop.initCfg();
                festival.luckshop && modelLuckShop.checkData(festival.luckshop);
            }
            if (actOrder.indexOf(TYPE_EXCHANGE) !== -1 && actCfg.act[TYPE_EXCHANGE]) {
                modelExchange.initCfg();
                festival.exchange && modelExchange.checkData(festival.exchange);
            }

            this.event(ModelFestival.UPDATE_DATA);
        }

        public function getActTabData():Array {
            var actOrder:Array = ObjectUtil.clone(actCfg.act_order) as Array;
            actOrder = actOrder.filter(function(id:String):Boolean {
                return Boolean(actCfg.act[id]) && this.activeCheck(id);
            }, this);
            var data:Array = actOrder.map(function (id:String):Object {
                var item:Object = actCfg.act[id];
                item.id = id;
                item.button = actCfg.button;
                item.selected = false;
                item.red = false;
                return item;
            });
            return data;
        }

        override public function get active():Boolean {
            var currentTime:int = ConfigServer.getServerTimer();
            if (!startTime || !endTime) return false;
            // 检测参与活动的资格
            var user:ModelUser = ModelManager.instance.modelUser;
            var serverStartTimer:int = user.gameServerStartTimer;
            if (!user.isMerge && startDay <= actCfg.blind_time)    return false; // (非合服区)活动开始前7天内开服的玩家不可参与
            return pf_visible && startTime < currentTime && endTime > (currentTime + 2000);
        }

        public function activeCheck(type:String):Boolean {
            switch(type)
            {
                case TYPE_LOGIN:
                    return modelLogin.active;
                case TYPE_ONCE:
                    return modelOnce.active;
                case TYPE_ADD_UP:
                    return modelAddUp.active;
                case TYPE_PIT_UP:
                    return modelPitUp.active;
                case TYPE_LUCK_SHOP:
                    return modelLuckShop.active;
                case TYPE_EXCHANGE:
                    return modelExchange.active;
                default:
                    return false;
            }
        }

        public function redCheck(type:String):Boolean {
            switch(type)
            {
                case TYPE_LOGIN:
                    return modelLogin.redPoint;
                case TYPE_ONCE:
                    return modelOnce.redPoint;
                case TYPE_ADD_UP:
                    return modelAddUp.redPoint;
                case TYPE_PIT_UP:
                    return modelPitUp.redPoint;
                case TYPE_LUCK_SHOP:
                    return modelLuckShop.redPoint;
                case TYPE_EXCHANGE:
                    return modelExchange.redPoint;
                default:
                    return false;
            }
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            if (!_id)   return false; // 活动不存在
            return modelLogin.redPoint || modelOnce.redPoint || modelAddUp.redPoint || modelPitUp.redPoint || modelExchange.redPoint || modelLuckShop.redPoint;
        }

        /**
         * @param 方法
         * @param 数据
         */
        override public function sendMethod(method:String, data:Object = null, handler:Handler = null, otherData:* = null):void {
            data || (data = {});
            NetSocket.instance.send(method, data, handler || Handler.create(this, this.sendCB));
        }
        
		/**
		 * @param	re
		 */
		private function sendCB(re:NetPackage):void {
			var gift_dict:* = re.receiveData['gift_dict'];
			ModelManager.instance.modelUser.updateData(re.receiveData);
			gift_dict && ViewManager.instance.showRewardPanel(gift_dict);
		}


        /**
         * 获得额外奖励["id","num"]
         * 现在有 attack_city_npc  pk_npc  gtask  visit  climb  pve
         */
        public static function getRewardInterfaceByKey(key:String):Array{
            var a:Array=[];
            if(ModelFestival.instance.active){
                var fm:ModelFestival=ModelFestival.instance;
                if(fm.actCfg && fm.actCfg.reward_interface && fm.actCfg.reward_interface[key]){
                    return fm.actCfg.reward_interface[key][1];
                }
            }
            return a;
        }

        /**
         * 广告弹板  没活动的话返回空数组
         * @return	["图片id",跳转位置]
         */
        public function get poster():Array {
            if (active && actCfg.poster) {
                return [actCfg.poster, {panelID: GotoManager.VIEW_FESTIVAL}];
            }
            return [];
        }
    }
}