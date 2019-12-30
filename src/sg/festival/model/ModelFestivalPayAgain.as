package sg.festival.model
{
    import sg.model.ViewModelBase;
    import sg.net.NetMethodCfg;
    import sg.activities.model.ModelActivities;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import laya.maths.MathUtil;

    public class ModelFestivalPayAgain extends ViewModelBase {

		// 单例
		private static var sModel:ModelFestivalPayAgain = null;
		public static function get instance():ModelFestivalPayAgain {
			return sModel ||= new ModelFestivalPayAgain();
		}
		public var cfg:Object = null; // 总配置
		private var data:Array;
        public function ModelFestivalPayAgain() {
        }

        /**
         * 更新数据
         */
        public function checkData(pay_again:Object):void {
            var actCfg:Object = ModelFestival.instance.actCfg;
            if (!actCfg) return;
            var cfgData:Object = actCfg.act[ModelFestival.TYPE_PAY_AGAIN];
            cfg = cfgData;
            var earliestEndTime:int = 0;
            this.data = pay_again.map(function(arr:Array, index:int):Object {
                var rewardCfg:Array = cfg.reward[arr[0]];
                var endTime:int = Tools.getTimeStamp(arr[1]);
                var finished:Boolean = arr[2] !== 0;
                if (!finished) {
                    if (earliestEndTime === 0 || endTime < earliestEndTime) {
                        earliestEndTime = endTime;
                    }
                }
                return {
                    index: index,
                    money: arr[0],
                    oriPrice: rewardCfg[0],
                    price: rewardCfg[1],
                    reward: rewardCfg[2],
                    endTime: endTime,
                    finished: finished
                };
            });
            this.event(ModelActivities.UPDATE_DATA);
            var currentTime:int = ConfigServer.getServerTimer();
            if (earliestEndTime > currentTime) {
                Laya.timer.once(earliestEndTime - currentTime, this, this._overdue);
            }
        }

        private function _overdue():void {
            ModelActivities.instance.refreshLeftList();
            this.event(ModelActivities.UPDATE_DATA);
        }

        public function remainTimes(money:int):int {
            return cfg.reward[money][3] - data.filter(function(obj:Object):Boolean {
                return obj.money === money;
            }).length;
        }

        public function getReward(index:int):void {
            this.sendMethod(NetMethodCfg.WS_SR_FESTIVAL_PAY_AGAIN, {reward_index: index});
        }

        public function get tabData():Array {
            var currentTime:int = ConfigServer.getServerTimer();
            return data && data.filter(function(obj:Object):Boolean {
                return currentTime < obj.endTime && !obj.finished;
            }).sort(MathUtil.sortByKey('money'));
        }
        
        override public function get active():Boolean {
            return tabData && tabData.length;
        }

        override public function get redPoint():Boolean {
            return active && true;
        }
    }
}