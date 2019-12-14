package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import sg.model.ModelUser;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;

    public class ModelAfficheMerge extends ViewModelBase
    {
		public static const SHOW_MERGE_BTN:String = 'merge_btn';
		public static var sModel:ModelAfficheMerge = null;
		public var mergeTime:int = 0;
		private var showDuration:int = 0; // 合服当天的偏移值时间
		public var endShowTime:int = 0; // 合服时间点
		public var info:String;
		public static function get instance():ModelAfficheMerge {
			return sModel ||= new ModelAfficheMerge();
		}

        public function ModelAfficheMerge() {
            var system_simple:Object = ConfigServer.system_simple; // 杂项全配置
            var currentTime:int = ConfigServer.getServerTimer();
            var user:ModelUser = ModelManager.instance.modelUser;
            // 检测合区时间点
            var mergeArr:Array = system_simple['merge_time_' + user.mergeNum];
            mergeArr && mergeArr.forEach(function(arr:Array):void {
                var zones:Array = arr[0];
                if (zones.some(function(zoneId:String):Boolean { return zoneId == user.mergeZone }, this)){
                    var t:Date = new Date(Tools.getTimeStamp(arr[1]));
                    endShowTime = t.getTime();
                    t.setHours(0, 0, 0, 0);
                    mergeTime = t.getTime() + system_simple.deviation * Tools.oneMinuteMilli;
                    showDuration = arr[3] * Tools.oneDayMilli;
                    info = Tools.getMsgById(arr[2], [t.getFullYear(), t.getMonth() + 1, t.getDate()]);
                }
            }, this);
            
            if (endShowTime && (endShowTime - showDuration) > currentTime) {
                Laya.timer.once(endShowTime - showDuration - currentTime, this, this._showMergeBtn);
            }
        }

        private function _showMergeBtn():void {
            this.event(SHOW_MERGE_BTN);
        }

        public function get remainTime():int {
            var currentTime:int = ConfigServer.getServerTimer();
            var remainTime:int = endShowTime - currentTime;
            remainTime = remainTime < 0 ? 0 : remainTime;
			return remainTime;
		}

		public function getTxt():String {
			return Tools.getMsgById('_jia0130') + '\n' + TimeHelper.formatTime(this.remainTime);
		}

		public function get mergeday():int {
            var user:ModelUser = ModelManager.instance.modelUser;
            if (endShowTime) {
                return user.getGameDate(endShowTime);
            }
			return 0;
		}

		/**
		 * 是否激活
		 */
		override public function get active():Boolean {
            var currentTime:int = ConfigServer.getServerTimer();
			return currentTime > (endShowTime - showDuration) && currentTime < endShowTime;
		}

		/**
		 * 是否需要显示红点
		 */
		override public function get redPoint():Boolean {
			return false;
		}
    }
}