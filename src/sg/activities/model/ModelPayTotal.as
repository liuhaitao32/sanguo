package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;
    import sg.utils.TimeHelper;

    public class ModelPayTotal extends ViewModelBase
    {
		public static const TYPE_DAYS:String = "days";	// 按开服时间开启的活动
		public static const TYPE_DATE:String = "date";	// 按实际时间开启的活动

		// 单例
		private static var sModel:ModelPayTotal = null;
		
		public static function get instance():ModelPayTotal {
			return sModel ||= new ModelPayTotal();
		}
		
        private var cfg:Object;
        private var _actId:Object = {};
        private var pay_ploy:Object;
        public function ModelPayTotal() {
            // 获取配置
            this.cfg = ConfigServer.ploy['pay_ploy'];
            haveConfig = Boolean(cfg);
        }

        override public function refreshData(data:*):void {
            if (!haveConfig || !data.pay_ploy) return;
            this.pay_ploy = data.pay_ploy;
            var tempKeys:Array = ObjectUtil.keys(pay_ploy);
            this._actId = {};
            for(var len:int = tempKeys.length - 1; len >= 0; len--) {
                var id:String = tempKeys[len];
                var element:Object = this.getConfigByID(id);
                if (!element) return;
                if (element.type === 'addup' && this.getRemainingTime(id)) {
                    element[TYPE_DATE] && (this._actId[TYPE_DATE] = id);
                    element[TYPE_DAYS] && (this._actId[TYPE_DAYS] = id);
                }
            }
            this.event(ModelActivities.UPDATE_DATA);
        }

        public function checkRewardByType(type:String):Boolean {
            var id:String = this.getIdByType(type);
            var cfg:* = this.getConfigByID(id);
            if(!cfg) return false;
            var data:Object = this.getDataByID(id);
            var pay_list:Array = data['pay_list'];
            var reward_list:Array = data['reward_list'];
            var totalPay:int = 0;
            var len:int = pay_list.length;
            for(var i:int = 0; i < len; i++) {
                totalPay += pay_list[i];
            }
            var keys:Array = ObjectUtil.keys(cfg['reward']);
            for(i = 0, len = keys.length; i < len; i++){
                var needMoney:int = parseInt(keys[i]);
                if (totalPay >= needMoney && reward_list.indexOf(needMoney) === -1) {
                    return true;
                }
            }
            return false;
        }

        public function checkActiveByType(type:String):Boolean {
            var id:String = this.getIdByType(type);
            return id && this.getConfigByID(id) && ModelManager.instance.modelUser.canPay;
        }

        override public function get active():Boolean {
            if (!haveConfig)    return false;
            return this.checkActiveByType(TYPE_DATE) || this.checkActiveByType(TYPE_DAYS);
        }

        public function getIdByType(type:String):String {
            return this._actId[type];
        }

        public function getConfigByID(id:String):Object {
            return this.cfg[id];
        }

        public function getDataByID(id:String):Object {
            return this.pay_ploy[id];
        }

        /**
         * 获取活动剩余时间
         */
        public function getRemainingTime(id:String):int {
            var cfg:Object = this.getConfigByID(id);
            // 检测活动时间
            var active:Boolean = false;
            var endTime:Number = 0;
            if (cfg.days) {
                var endDays:int = cfg.days[1];
                endTime = ModelManager.instance.modelUser.gameServerStartTimer + Tools.oneDayMilli * endDays;
            }
            else if (cfg.date) {
                var endDate:Array = cfg.date[1];
                endTime =  new Date(endDate[0], endDate[1] - 1, endDate[2]).getTime() + ConfigServer.system_simple.deviation * Tools.oneMinuteMilli;
            }
            var currentTime:int = ConfigServer.getServerTimer();
            var mergeTime:int = ModelAfficheMerge.instance.mergeTime;
            var remainingTime:int = (mergeTime && mergeTime < endTime ? mergeTime: endTime) - currentTime;
            return remainingTime < 0 ? 0 : remainingTime;
        }

        /**
         * 获取活动剩余时间（字符串）
         */
        public function getTimeString(grade:String):String {
            return TimeHelper.formatTime(this.getRemainingTime(grade));
        }
    }
}