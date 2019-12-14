package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;

    public class ModelPromote extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelPromote = null;
		
		public static function get instance():ModelPromote
		{
			return sModel ||= new ModelPromote();
		}
		
        private var payMoney:int = 0;
        public var cfg:Object;
        private var rewardObject:Object;
        private var rewardKeys:Array;
        private var office_reward:Array;
        public function ModelPromote()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['act_officeup'];
            haveConfig = Boolean(cfg);
            if (haveConfig) {
                this.rewardObject = this.cfg.officelv_reward;
                this.rewardKeys = ObjectUtil.keys(this.rewardObject);
            }
        }

        override public function refreshData(data:*):void {
            if (!haveConfig || !data.office_reward) return;
            var reward:Array = data.office_reward;
            reward && (this.office_reward = reward);
            this.payMoney = ModelManager.instance.modelUser.records.pay_money || 0;
            this.event(ModelActivities.UPDATE_DATA);
        }

        public function getPayMoney():int {
            return this.payMoney;
        }

        public function getFlagWithGrade(grade:*):int {
            if (this.office_reward.indexOf(+grade) !== -1)    return 2;
            if (this.payMoney < this.cfg['pay_money'] || ModelManager.instance.modelUser.office < grade)  return 0;
            return 1;
        }

		override public function get active():Boolean {
            return ModelManager.instance.modelUser.canPay && office_reward is Array && rewardKeys is Array && office_reward.length < rewardKeys.length;
        }

		override public function get redPoint():Boolean {
            return this.checkReward();
        }

        /**
         * 检测是否存在未领取奖励
         */
        public function checkReward():Boolean
        {
            var keys:Array = this.getRewardKeys();
            var len:int = keys.length;
            for(var i:int = 0; i < len; i++)
            {
                if (this.getFlagWithGrade(keys[i]) === 1) {
                    return true;
                }
            }
            return false;
        }

        public function getRewardObject(key:String):Object
        {
            return this.rewardObject[key];
        }

        public function getRewardKeys():Array
        {
            return this.rewardKeys;
        }

        public function getReward(grade:int):void
        {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_OFFICE_REWARD, {'office': grade});
        }
    }
}