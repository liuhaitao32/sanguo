package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.ObjectUtil;
    import sg.utils.ArrayUtil;
    import sg.model.ModelGame;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.utils.Tools;
    import sg.cfg.ConfigApp;
    import sg.manager.ViewManager;
    import sg.utils.SaveLocal;
    import sg.model.ModelUser;

    public class ModelSurpriseGift extends ViewModelBase
    {
		public static const RED_KEY:String = 'red_key_surprise_gift';
		// 单例
		private static var sModel:ModelSurpriseGift = null;		
		public static function get instance():ModelSurpriseGift {
			return sModel ||= new ModelSurpriseGift();
		}

        public var cfg:Object = null;
        private var startTime:Number = 0; // 开始时间
        private var endTime:Number = 0; // 结束时间
        private var beginTime:Number = 0; // 本期活动最开始时间
        private var finalTime:Number = 0; // 最终时间
        public var days:Array;
        private var actId:String = '';
        public var goodsData:Array = [];
        public var _rTime:Number = Number.MAX_VALUE;
        public var _startTime:int = 0;
        public function ModelSurpriseGift(){
            // 获取配置
            this.cfg = ConfigServer.ploy['surprise_gift'];
            haveConfig = Boolean(cfg);
            SaveLocal.save(ModelSurpriseGift.RED_KEY, {day: 0}, true);
        }

        override public function refreshData(data:*):void {
            actId = this.seekId();
            if (!actId || !data || !haveConfig) return;
            days = actId.split('_').map(function(dayId:String):int {return parseInt(dayId)}, this);
            days = days[0] === days[1] ? [days[0]] : days;
            var finalDay:int = days[days.length - 1];
            startTime = Tools.getTodayMillWithHourAndMinute(cfg.active_time[0]);
            endTime = Tools.getTodayMillWithHourAndMinute(cfg.active_time[1]);
            var user:ModelUser = ModelManager.instance.modelUser;
            beginTime = startTime + (days[0] - user.getGameDate()) * Tools.oneDayMilli
            finalTime = endTime + (finalDay - user.getGameDate()) * Tools.oneDayMilli;
            var payList:Array = user.getPayList(true);
            var keys:Array = ObjectUtil.keys(cfg[actId]).map(function(key:String):Object { return parseInt(key); }).sort(function(a:int, b:int):Boolean { return a < b; });
            goodsData = keys.map(function(money:int):Object { 
                var obj:Object = cfg[actId][money];
                var payObj:Object = ArrayUtil.find(payList, function(obj:Object):Object { return obj.cost_cfg === money });
                var exclusion:Array = cfg[actId][money].exclusion;
                var buy_times:int = (data[actId] && data[actId][money]) || 0;
                if (buy_times > obj.num)    buy_times = obj.num;
                obj.money = payObj ? user.getPayMoney(payObj.id, money) : money;
                obj.pid = payObj ? payObj.id : '';
                obj.buy_times = buy_times;
                obj.excluded = exclusion && exclusion.indexOf(ConfigApp.pf) !== -1;
                return obj;
            }).sort(function(a:Object, b:Object):Boolean {return a.money - b.money});
            this.event(ModelActivities.UPDATE_DATA);
            
            var currentTime:int = ConfigServer.getServerTimer();
            if (currentTime < startTime) {
                Laya.timer.once(startTime - currentTime + Tools.oneMillis, this, this.eventStart);
            }
            if (currentTime < endTime) {
                Laya.timer.once(endTime - currentTime + Tools.oneMillis, this, this.eventEnd);
            }
            if (currentTime < finalTime) {
                // console.group('surprise');
                // console.log('surprise 开始时间: ', currentTime);
                // console.log('surprise 计划用时: ', finalTime - currentTime + Tools.oneMillis);
                // console.groupEnd();
                // console.time('surprise');
                Laya.timer.once(finalTime - currentTime + Tools.oneMillis, this, this.eventClose);
            }
        }

        private function eventStart():void {
            this.event(ModelActivities.UPDATE_DATA);
        }

        private function eventEnd():void {
            this.event(ModelActivities.UPDATE_DATA);
        }

        private function eventClose():void {
            // console.group('surprise');
            // console.log('surprise 关闭时间: ', finalTime);
            // console.log('surprise 当前时间: ', ConfigServer.getServerTimer());
            // console.groupEnd();
            // console.timeEnd('surprise');
            this.event(ModelActivities.UPDATE_DATA);
            ModelActivities.instance.refreshLeftList();
        }

        private function seekId():String {
            return ArrayUtil.find(ObjectUtil.keys(cfg), function(id:String):Boolean {
                if (!(/\d+_\d+/.test(id)))    return false;
                var num:int = ModelManager.instance.modelUser.getGameDate();
                var days:Array = id.split('_').map(function(str:String):int { return parseInt(str) }, this);
                if (days[0] === days[1]) {
                    return days[0] === num;
                }
                return num >= days[0] && num <= days[1];
            }, this);
        }

        public function butGoods(pid:String):void {
            if (ConfigServer.getServerTimer() > finalTime) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('happy_tips07'));
            } else if (pid) {
                ModelGame.toPay(pid);
            } else {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('surprise_12'));
            }
        }

        /**
         * 入口倒计时
         */
        public function getTime():int {
            var currentTime:int = ConfigServer.getServerTimer();
            var foreshow:Boolean = currentTime < startTime && ModelManager.instance.modelUser.getGameDate() === days[0];
            return (foreshow ? startTime : finalTime) - currentTime;
        }

		public function get notStart():Boolean {
            var currentTime:int = ConfigServer.getServerTimer();
			return currentTime < startTime || (currentTime > endTime && currentTime < finalTime);
		}

		public function get timeHintTxt():String {
            var currentTime:int = ConfigServer.getServerTimer();
            var foreshow:Boolean = currentTime < startTime && ModelManager.instance.modelUser.getGameDate() === days[0];
            return Tools.getMsgById(foreshow ? '_jia0056' : '_jia0052');
		}

		override public function get active():Boolean {
            var notEnd:Boolean = ConfigServer.getServerTimer() < finalTime;
            if (cfg.forbid_time) {
                return beginTime < Tools.getTimeStamp(cfg.forbid_time) && notEnd;
            }
			return ModelManager.instance.modelUser.canPay && notEnd;
		}
        
		override public function get redPoint():Boolean {
            var currentTime:int = ConfigServer.getServerTimer();
            var data:Object = SaveLocal.getValue(RED_KEY, true)
            var value:int = data ? data.day : 0;
            return currentTime > startTime && currentTime < endTime && ModelManager.instance.modelUser.getGameDate() !== value;
        }
    }
}