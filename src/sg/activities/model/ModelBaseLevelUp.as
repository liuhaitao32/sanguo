package sg.activities.model
{
    import laya.events.EventDispatcher;
    import sg.boundFor.GotoManager;
    import sg.cfg.ConfigServer;
    import sg.net.NetMethodCfg;
    import sg.utils.Tools;
    import sg.utils.ObjectUtil;
    import sg.utils.TimeHelper;
    import sg.model.ViewModelBase;
    import sg.manager.ModelManager;
    public class ModelBaseLevelUp extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelBaseLevelUp = null;
		
		public static function get instance():ModelBaseLevelUp
		{
			return sModel ||= new ModelBaseLevelUp();
		}
		
        public var cfg:Object;
        public var title:String;
        public var tips:String;
        public var tab_name:String;
        public var character:String;
        private var lvup_reward:Object;
        private var leveUpKeys:Array;
        public function ModelBaseLevelUp()
        {
            // 获取配置
            cfg = ConfigServer.ploy['levelup'];
            haveConfig = Boolean(cfg);
            if (haveConfig) {
                this.title = cfg['title'];         
                this.tips = cfg['tips'];         
                this.tab_name = cfg['tab_name'];         
                this.character = cfg['character'];
            }
        }

        override public function refreshData(reward:*):void {
            if (!haveConfig) return;         
            // 获取用户数据
            this.lvup_reward = reward;
            var keys:Array = ObjectUtil.keys(reward);
            this.leveUpKeys = [];
            for(var i:int = 0, len:int = keys.length; i < len; ++i) {
                (this.getRemainingTime(keys[i]) || this.checkRewardActive(keys[i])) && this.leveUpKeys.push(keys[i]);
            }
            this.event(ModelActivities.UPDATE_DATA);
        }

        // 获取活动剩余时间
        public function getRemainingTime(grade:String):int
        {
            var data:Object = this.lvup_reward[grade];
            // var endTime:int = Tools.getTimeStamp(data[1]) + this.cfg.time * 1000;
            var endTime:int = Tools.getTimeStamp(data[1]);
            var currentTime:int = ConfigServer.getServerTimer();
            var remainingTime:int = endTime - currentTime;
            return remainingTime < 0 ? 0 : remainingTime;
        }

        /**
         * 获取活动剩余时间（字符串）
         */
        public function getTimeString(grade:String):String
        {
            return TimeHelper.formatTime(this.getRemainingTime(grade));
        }

        /**
         * 检测是否可以领奖
         */
        public function checkRewardActive(grade:String):Boolean
        {
            var data:Object = this.lvup_reward[grade];
            return data[0] >= this.cfg.reward[grade][0];
        }

        override public function get active():Boolean {
            return haveConfig && ModelManager.instance.modelUser.canPay && this.getCurrentNums() > 0;
        }

        /**
         * 检测有无可领取奖励
         */
        override public function get redPoint():Boolean {
            var keys:Array = this.getLevelUpKeys();
            var len:int = keys.length;
            for(var i:int = 0; i < len; i++)
            {
                if (this.checkRewardActive(keys[i])){
                    return true;
                }
            }
            return false;
        }

        /**
         * 获取开启的活动ID
         */
        public function getLevelUpKeys():Array
        {
            return this.leveUpKeys;
        }

        /**
         * 获取当前活动数量
         */
        public function getCurrentNums():int
        {
            return this.leveUpKeys.length;
        }

        /**
         * 获取已充值金额
         */
        public function getCurrentMoney(grade:String):int
        {
            return this.lvup_reward[grade][0] * 10;
        }

        /**
         * 获取领奖需要充值的黄金
         */
        public function getNeedMoney(grade:String):String
        {
            return this.cfg.reward[grade][0] * 10 + '';
        }

        public function getReward(grade:String):void
        {
            if (this.checkRewardActive(grade)) {
                ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_LVUP_REWARD, {reward_key: parseInt(grade)});
            }
			else {
                GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
            }
        }

    }
}