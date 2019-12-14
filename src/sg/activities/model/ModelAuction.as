package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import sg.utils.Tools;
    import sg.model.ModelHero;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ViewManager;
    import laya.utils.Handler;
    import sg.boundFor.GotoManager;
    import sg.view.hero.ViewAwakenHero;
    import sg.utils.TimeHelper;
    import sg.utils.ObjectUtil;
    import sg.net.NetSocket;
    import laya.maths.MathUtil;
    import sg.activities.view.AuctionRefund;
    import sg.guide.model.ModelGuide;

    public class ModelAuction extends ViewModelBase
    {
		public static const STATE_BEFORE:String     = 'before'; // 拍卖尚未开始
		public static const STATE_AUCTION:String    = 'auction';// 拍卖开始
		public static const STATE_BUY:String        = 'buy';    // 拍卖结束 可以购买
		public static const STATE_SHOW:String       = 'show';   // 拍卖结束 展示得主
		public static const STATE_ENDED:String      = 'end';    // 购买结束或展示结束

		// 单例
		private static var sModel:ModelAuction = null;
		public static function get instance():ModelAuction {
			return sModel ||= new ModelAuction();
		}
		
        public var cfg:Object;
        public var foreshowTime:int = 0;// 预告时间
        public var noticeTime_begin:int = 0;  // 开始提醒时间
        public var noticeTime_end:int = 0;  // 结束提醒时间
        public var beginTime:int = 0;   // 拍卖开始时间
        public var endTime:int = 0;     // 拍卖结束时间
        public var latestTime:int;  // 落锤时间
        public var closeTime:int;   // 入口关闭时间
        public var actId:int;       // 当前活动ID
        public var nextId:int;      // 下一次活动ID
        public var buyData:Array;   // 个人拍卖数据
        public var sData:Array;     // 拍卖数据（服务器）
        public var bidUids:Array = [];   // 两个礼包最高出价人的UID
        public var bidUnames:Object = {};   // 两个礼包最高出价人的名字
        public var bidCountrys:Object = {};   // 两个礼包最高出价人的国家
        public var endFlags:Array = [null, null]; // 记录两个拍卖是否结束
        public var owner_contents:Array; // 两个礼包最高出价人的购买信息
        public function ModelAuction()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['auction'];
            haveConfig = Boolean(cfg);
            nextId = Infinity;
        }

        /**
         * 更新个人的拍卖数据
         */
        override public function refreshData(data:*):void {
            if (!haveConfig)    return;
            // 刷新时间
            beginTime = Tools.getTodayMillWithHourAndMinute(cfg.begin_time);
            latestTime = Tools.getTodayMillWithHourAndMinute(cfg.latest_time);
            var library:Object = cfg.library;

            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var id:int = modelUser.getGameDate();
            var oneDayMilli:int = Tools.oneDayMilli;
            var open_date:int = Tools.getTimeStamp(cfg.open_date); // 活动上架时间
			var openServerTimer:Number = Tools.getTimeStamp(ConfigServer.zone[""+modelUser.zone][2]); // 开服时间点
            if (open_date > openServerTimer) { // 减去活动上架之前经过的天数
                id -= Math.floor(open_date / oneDayMilli) - Math.floor(openServerTimer / oneDayMilli);
            }
            var tempId:int = actId;
            actId = library[id] ? id : -1; // 活动ID
            buyData = data[0] !== actId ? [] : data[1];
            var currentTime:int = ConfigServer.getServerTimer();
            if (actId > 0 && tempId !== actId) { // 第一次获取到活动id
                this.refreshGlobalData({'data': sData});

                // 活动开始时刷新数据
                currentTime < beginTime && Laya.timer.once(beginTime - currentTime, this, this.getAuction);
            }

            if (actId > 0 && this.active) { // 今天有活动 刷新界面
                nextId = Infinity;

                // 刷新定时器以及数据
                this.refreshEvent();
            }
            else { // 今天没活动 获取下一个活动ID
                actId = -1;
                nextId = Infinity;
                var keys:Array = ObjectUtil.keys(library);
                keys.forEach(function(key:String, index:int):void {
                    var tempNum:int = parseInt(key);
                    if (tempNum > id && tempNum < nextId) {
                        nextId = tempNum;
                    }
                }, this);
                if (nextId !== Infinity) { // 获取下次活动的开启时间
                    beginTime = Tools.getTodayMillWithHourAndMinute(cfg.begin_time) + (nextId - id) * Tools.oneDayMilli;
                    if (beginTime >= ModelAfficheMerge.instance.mergeTime) {
                        beginTime = 0;
                        actId = -1;
                        nextId = Infinity;
                    }
                }
            }

            foreshowTime = beginTime - cfg.notice[0] * Tools.oneMillis; // 预告时间
            noticeTime_begin = beginTime - cfg.notice[1] * Tools.oneMillis; // 提醒时间

            // 计算结束的通知时间（根据配置的开始时间和结束时间进行推导）
            noticeTime_end = beginTime + Tools.getTodayMillWithHourAndMinute(cfg.end_time) - Tools.getTodayMillWithHourAndMinute(cfg.begin_time) - cfg.add_time[0] * Tools.oneMillis;

            if (beginTime > open_date) {
                foreshowTime = open_date > foreshowTime ? open_date : foreshowTime;
                noticeTime_begin = open_date > noticeTime_begin ? open_date : noticeTime_begin;
            
                // 通知玩家拍卖即将开始
                if (noticeTime_begin > currentTime) {
                    Laya.timer.once(noticeTime_begin - currentTime, this, function():void {
                        if (!this.active || nextId !== Infinity)    return;
                        ViewManager.instance.showTipsTxt(Tools.getMsgById(cfg.notice[2], [TimeHelper.formatTime(this.getTime())]));
                    });
                }
                
                // 刷新游戏入口
                if (foreshowTime > currentTime) {
                    Laya.timer.once(foreshowTime - currentTime, ModelActivities.instance, ModelActivities.instance.refreshLeftList);
                }
                
                // 通知拍卖即将结束
                if (noticeTime_end > currentTime) {
                    Laya.timer.once(noticeTime_end - currentTime, this, this._sendEndMsg);
                }
            }
            this.event(ModelActivities.UPDATE_DATA);
        }


        /**
         * 更新全局的拍卖数据
         */
        public function refreshGlobalData(data:*):void {
            if (!data || !haveConfig) return; // 容错
            sData = data.data;
            if (!sData || !sData.length) return; // 容错
            sData.forEach(function(arr:Array, index:int):void { // 刷新结束时间
                var t:int = Tools.getTimeStamp(arr[2]);
                endTime = endTime < t ? t : endTime;
            }, this);

            if (actId <= 0) return; // 今天没活动

            // 检查结束 （全服推送消息）
            this._checkEnd();

            // 检查退款
            this._checkRefund();
            this.refreshEvent();
            this.event(ModelActivities.UPDATE_DATA);
            ModelActivities.instance.refreshLeftList();
        }

        public function _checkEnd():void {
            endFlags.forEach(function(value:int, index:int):void {
                endFlags[index] === null && (endFlags[index] = sData[index][3]);
            });

            // 检测同时结束
            endFlags.every(function(value:int):Boolean { 
                return value === 0;
            }) && sData.every(function(arr:Array):Boolean { 
                var uid:int = arr[1];
                return (uid is Number) && uid > 0 && arr[3];
            }) && Laya.timer.once(Tools.oneMillis, this, this._showTwoOwner);
            
            // 单个检查
            endFlags.forEach(function(value:int, index:int):void {
                endFlags[index] === 0 && sData[index][3] && Laya.timer.once(Tools.oneMillis, this, this._showOwner, [index], false);
            }, this);

            var currentTime:int = ConfigServer.getServerTimer();
            var endTime0:int = Tools.getTimeStamp(sData[0][2]);
            var endTime1:int = Tools.getTimeStamp(sData[1][2]);
            if (endTime0 > currentTime || endTime1 > currentTime) {
                Laya.timer.once((endTime0 > endTime1 ? endTime0 : endTime1) - currentTime + 200, this, this.getAuction);
            }

            var duration_buy:int = cfg.buy_time * Tools.oneMillis;
            endTime0 += duration_buy;
            endTime1 += duration_buy;
            
            // 计算活动最终结束时间
            var finalTime:int = endTime0 > endTime1 ? endTime0 : endTime1;
            if (finalTime > currentTime) {
                Laya.timer.once(finalTime - currentTime + 200, this, this._pushOverMsg);
            }
        }

        /**
         * 检查是不是我拍卖成功了
         */
        private function _checkUid(index:int):void {
            if (sData[index] && sData[index][3] && sData[index][1] == ModelManager.instance.modelUser.mUID) {
                ModelManager.instance.modelGame.showMailByTitle(Tools.getMsgById(cfg.msg_reward[0]));
            }
        }

        private function _pushOverMsg():void {
            if (actId === -1)   return;
            var flag:Boolean = sData.every(function(arr:Array, index:int):Boolean { // 检测是否存在购买环节
                var topPrice:int = cfg.library[actId][index][1];
                return topPrice !== -1;
            }, this);

            var content:String = Tools.getMsgById(cfg.end_text); // 内容
            Laya.timer.once((flag ? 0.1 :  5) * Tools.oneMillis, this, function():void {
                this.event(ModelActivities.UPDATE_DATA);
                ModelActivities.instance.refreshLeftList();
                ViewManager.instance.showHintPanel(
                    content,
                    null,
                    [{'name': Tools.getMsgById('_public183')}]
                );
            });

            var auctionData:Object = ModelManager.instance.modelUser.records.auction;
            auctionData && this.refreshData(auctionData);

            this.refreshEvent();
        }

        /**
         * 展示礼包的拥有者
         */
        private function _showOwner(index:int):void {
            var uid:int = this.sData[index][1];
            endFlags[index] = sData[index][3];
            this._checkUid(index);
            if ((uid is Number) && uid > 0) {
                var hid:String = listData[index].hid;
                var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
                var heroName:String = Tools.getMsgById(md.name);
                var giftName:String = Tools.getMsgById('550029', [heroName]);
                var content:String = Tools.getMsgById(cfg.show, [bidUnames[uid], giftName]); // 内容

                ViewManager.instance.showTipsTxt(content, 4);
            }
            this.event(ModelActivities.UPDATE_DATA);
        }

        private function ws_sr_user_info(np:NetPackage):void {
            var data:Object = np.receiveData;
            var uid:int = np.otherData;
            bidUnames[uid] = data.uname;
            bidCountrys[uid] = data.country;
        }

        /**
         * 同时展示两个礼包的拥有者
         */
        private function _showTwoOwner():void {
            owner_contents = [];
            endFlags.forEach(function(value:int, index:int):void { 
                this.get_user_show(bidUids[index], index);
                endFlags[index] = sData[index][3];
                this._checkUid(index);
            }, this);
            owner_contents.reverse(); // 重新排序
            ViewManager.instance.showTipsTxt(owner_contents.join('<br/>'), 4);
        }

        private function get_user_show(uid:int, index:int):void {
            var uname:String = bidUnames[uid];
            var hid:String = listData[index].hid;
            var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
            var heroName:String = Tools.getMsgById(md.name);
            var giftName:String = Tools.getMsgById('550029', [heroName]);
            var content:String = Tools.getMsgById(cfg.show, [uname, giftName]); // 内容
            owner_contents.push(content);
        }

        public function refreshEvent():void {
            Laya.timer.clear(this, this.refreshEvent);
            if (this.getState(0) === STATE_BEFORE) {
                this.getTime() > 0 && Laya.timer.once(this.getTime(), this, this._showStart);
            }
        }

        /**
         * 拍卖活动开始
         */
        private function _showStart():void {
            ViewManager.instance.showTipsTxt(Tools.getMsgById('550036'));
            this.refreshEvent();
        }

        /**
         * 检查是否需要退款（自己的出价是否被超越）
         */
        private function _checkRefund():void {
            var user:ModelUser = ModelManager.instance.modelUser;
            var mUID:int = parseInt(user.mUID);
            sData.forEach(function(arr:Array, index:int):void {
                var uid:int = arr[1];
                if (isNaN(uid) || uid <= 0) return;
                var flag:Boolean = bidUids[index] == mUID && uid != mUID; // 竞价被超越
                var hid:String = cfg.library[user.auction.open_days][index][2].awaken[0];
                var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
                var title:String = Tools.getMsgById('550038', [Tools.getMsgById('550029', [Tools.getMsgById(md.name)])]);
                flag && this._showRefund(title);
                if (bidUids[index] !== uid) {
                    bidUids[index] = uid;
                    var remainTime:int = Tools.getTimeStamp(sData[index][2]) - ConfigServer.getServerTimer();
                    if (remainTime > 0 && remainTime <=  cfg.add_time[1] * Tools.oneMillis) {
                        this._sendHintMsg(index);
                    }
                }
            }, this);

            active && bidUids.forEach(function(uid:int):void {
                if (!bidUnames[uid]) {
                    NetSocket.instance.send(NetMethodCfg.WS_SR_USER_INFO,{uid: uid}, Handler.create(this,this.ws_sr_user_info), uid);
                }
            }, this);
        }

        public function get listData():Array {
            var data:Array = cfg.library[actId > 0 ? actId: nextId];
            if (!data)  return [];
            var currentTime:int = ConfigServer.getServerTimer();
            var listArr:Array = data.map(function(arr:Array, index:int):Object {
                var giftdict:Object = arr[2];
                var hid:String = giftdict.awaken[0]; // [0] 礼包里只有一个觉醒英雄
                var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
                var chipNum:int = giftdict[md.itemID];
                var auctionData:Array = (sData is Array && sData.length) ? sData[index] : [];
                return {
                    index: index,
                    startPrice: arr[0],
                    topPrice: arr[1],
                    currentPrice: auctionData[0] || arr[0],
                    uid: auctionData[1],
                    endTime: auctionData[2],
                    auctionEnd: currentTime > Tools.getTimeStamp(auctionData[2]),
                    hid: hid,
                    chipNum: chipNum || 0
                };
            }, this);
            return listArr;
        }

        /**
         * 获取拍卖活动的当前状态
         */
        public function getState(index:int):String {
            var currentTime:int = ConfigServer.getServerTimer();
            if (currentTime < beginTime) {
                return STATE_BEFORE;
            }
            if (!buyData) return STATE_ENDED;
            if (!sData || !sData.length) return STATE_ENDED;
            var auctionData:Array = sData[index];
            if (!auctionData) return STATE_ENDED;
            var endTime2:int = Tools.getTimeStamp(auctionData[2]);
            var auctionEnd:Boolean = currentTime > endTime2 + cfg.buy_time * Tools.oneMillis;
            if (auctionEnd) {
                return STATE_ENDED;
            }
            if (buyData.indexOf(index) !== -1) {
                return STATE_SHOW;
            }
            if (currentTime > endTime2) {
                if (cfg.library[actId][index][1] <= 0) {
                    return STATE_SHOW;
                }
                return STATE_BUY;
            }
            return STATE_AUCTION;
        }

        /**
         * 活动剩余时间
         */
        public function getTimeByIndex(index:int):int {
            var state:String = this.getState(index);
            var currentTime:int = ConfigServer.getServerTimer();
            var auctionData:Array = sData[index];
            switch(state)
            {
                case STATE_BEFORE:
                    return this.getTime();
                case STATE_AUCTION:
                    return Tools.getTimeStamp(auctionData[2]) - currentTime;
                case STATE_BUY:
                case STATE_SHOW:
                    return Tools.getTimeStamp(auctionData[2]) + cfg.buy_time * Tools.oneMillis - currentTime;
            }
            return 0;
        }

        /**
         * 入口倒计时
         */
        public function getTime():int {
            var currentTime:int = ConfigServer.getServerTimer();
            if (actStart) {
                return completeTime - currentTime;
            }
            else {
                return beginTime - currentTime;
            }
        }

        /**
         * 活动是否已经开始
         */
        public function get actStart():Boolean {
            var currentTime:int = ConfigServer.getServerTimer();
            return currentTime >= beginTime;
        }

        /**
         * 获取结束时间（拍卖结束时间和购买结束时间）
         * 优先获取拍卖结束时间
         */
        public function get completeTime():int {
            var currentTime:int = ConfigServer.getServerTimer();
            var actEndTime:int = 0;
            actId > 0 && sData.forEach(function(arr:Array, index:int):void {
                var topPrice:int = cfg.library[actId][index][1];
                var t1:int = Tools.getTimeStamp(arr[2]); // 拍卖结束时间
                actEndTime = t1 > actEndTime ? t1 : actEndTime;
                if (currentTime >= t1 && topPrice > 0) { // 购买或单纯展示 
                    var t2:int = t1 + cfg.buy_time * Tools.oneMillis; // 购买结束时间
                    actEndTime = t2 > actEndTime ? t2 : actEndTime;
                }
            });
            return actEndTime;
        }

        override public function get active():Boolean {
            if (!haveConfig)    return false;
            var currentTime:int = ConfigServer.getServerTimer();
            if (actId > 0) { // 今天有活动
                return currentTime > (beginTime - cfg.notice[0] * Tools.oneMillis) && currentTime < completeTime;
            }
            return nextId !== Infinity && currentTime >= (beginTime - cfg.notice[0] * Tools.oneMillis);
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            return active && sData && sData.length && sData.some(function(arr:Array, index:int):Boolean {
                var state:String = this.getState(index);
                var canAuction:Boolean = state === STATE_AUCTION && arr[1] != modelUser.mUID && modelUser.coin >= (arr[0] + cfg.unit); // 可以拍
                var canBuy:Boolean = state === STATE_BUY && modelUser.coin >= cfg.library[actId][index][1]; // 可以买
                return canAuction || canBuy;
            }, this);
        }

        /**
         * 获取拍卖数据
         */
        public function getAuction():void {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_AUCTION);
        }

        /**
         * 出价
         */
        public function bid(cost:int, index:int):void {
            this.sendMethod(NetMethodCfg.WS_SR_COST_AUCTION, {cost_coin: cost, auction_index: index}, Handler.create(this, this.bidCB));
        }
        
		private function bidCB(np:NetPackage):void {
            var rd:Object = np.receiveData;
            if (rd.gift_dict) { // 秒杀觉醒英雄礼包
                ViewAwakenHero.checkGiftDict(rd.gift_dict);
                ViewManager.instance.showRewardPanel(rd.gift_dict);
            }
			else {
                ViewManager.instance.showTipsTxt(Tools.getMsgById(cfg.bingo));
            }
			ModelManager.instance.modelUser.updateData(rd); // 先检查是否需要招募再更新
		}

        /**
         * 购买
         */
        public function buy(index:int, cancel:int):void {
            cancel || this.sendMethod(NetMethodCfg.WS_SR_BUY_AUCTION, {auction_index: index});
        }

        /**
         * 展示退款
         */
        private function _showRefund(tips:String):void {
            if (ModelGuide.forceGuide()) {
                return;
            }
            GotoManager.boundForPanel(GotoManager.VIEW_AUCTION);
            var _title:String = Tools.getMsgById(cfg.msg_surpass[0]);

			NetSocket.instance.send("get_msg",{},Handler.create(this,function(np:NetPackage):void{
				var sysData:Array=[];
				var userData:Object=np.receiveData.user.msg;
				var a:Array=userData.sys;
				for(var i:int=0;i<a.length;i++){
					var o:Object={};
					var d:Array=a[i];
					o["title"]=d[0];
					o["info"]=d[1];
					o["gift"]=d[2];
					o["time"]=d[3];
					o["paixu"]=Tools.getTimeStamp(d[3]);
					o["index"]=i;
					o["isOpen"]=d[4];
					sysData.push(o);
				}
				sysData.sort(MathUtil.sortByKey("paixu",true,false));
				
                var refundData:Object = null;
				for(var j:int=0;j<sysData.length;j++){
					if(sysData[j] && sysData[j].isOpen==0  && sysData[j].title==_title){
						refundData = sysData[j];
						refundData.index = j;
						refundData.tips = tips;
						break;
					}
				}

				if(refundData){
                    ViewManager.instance.showView(["AuctionRefund", AuctionRefund], refundData);
				}
				
			}));
		}

        private function _sendEndMsg():void {
            if (!active || nextId !== Infinity)    return;
            var arr:Array = [Math.floor(cfg.add_time[0] / 60), Math.floor(cfg.add_time[1] / 60), cfg.latest_time.join(':')];
            ModelManager.instance.modelChat.sendLocalMessage([0, "auction_end", "1", arr, ConfigServer.getServerTimer()]);
        }

        private function _sendHintMsg(index:int):void {
            var hid:String = listData[index].hid;
            var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
            var heroName:String = Tools.getMsgById(md.name);
            var giftName:String = Tools.getMsgById('550029', [heroName]);
            var price:int = sData[index][0];
            var time:String = sData[index][2]['$datetime'].match(/(\d{2}:\d{2}):\d{2}/)[1];
            var arr:Array = [giftName, price, time];
            ModelManager.instance.modelChat.sendLocalMessage([0, "auction_end", "2", arr, ConfigServer.getServerTimer()]);
        }
    }
}