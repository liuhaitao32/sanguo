package sg.festival.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;
    import sg.utils.Tools;
    import sg.net.NetMethodCfg;

    public class ModelFestivalPitUp extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelFestivalPitUp = null;
		
		public static function get instance():ModelFestivalPitUp {
			return sModel ||= new ModelFestivalPitUp();
		}
		
        private var _cfg:Object = null;
        public var payMoney:int = 0;
        public var needPay:int = 0;
        public var rewardIndex:int = 0;
        public var rewardData:Object = null;
        public function ModelFestivalPitUp() {
        }

        /**
         * 设置配置数据
         */
        public function initCfg():void {
            var actCfg:Object = ModelFestival.instance.actCfg;
            var cfgData:Object = actCfg.act[ModelFestival.TYPE_PIT_UP];
            _cfg = cfgData;
        }

        /**
         * 更新数据
         */
        public function checkData(pit_up_index:int, pit_up_pay:int):void {
            rewardIndex = pit_up_index;
            payMoney = pit_up_pay;

            var reward:Array = _cfg.reward;
            if (rewardIndex < reward.length) {
                needPay = reward[rewardIndex][0];
                rewardData = reward[rewardIndex][1];
            } else {
                needPay = reward[reward.length - 1][0];
                rewardData = reward[reward.length - 1][1];
            }
        }

        public function get rewardAllReceived():Boolean {;
            return rewardIndex >= _cfg.reward.length;
        }

        public function get rewardActive():Boolean {;
            return rewardIndex < _cfg.reward.length && payMoney >= needPay;
        }

        public function getRewardData():Array {
            var rewardCfg:Array = _cfg.reward;
            var reward:Object = rewardCfg[rewardIndex >= rewardCfg.length ? rewardCfg.length - 1 : rewardIndex][1];
            return ModelManager.instance.modelProp.getRewardProp(reward);
        }

        public function get cfg():Object {
            return _cfg;
        }

        override public function get active():Boolean {
            return ModelManager.instance.modelUser.canPay && Boolean(_cfg);
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            return active && rewardActive;
        }

        /**
         * 领奖
         */
        public function getReward():void {
            ModelFestival.instance.sendMethod(NetMethodCfg.WS_SR_FESTIVAL_PITUP_REWARD);
        }
    }
}