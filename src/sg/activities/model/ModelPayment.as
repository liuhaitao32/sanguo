package sg.activities.model
{
    import laya.events.EventDispatcher;

    import sg.boundFor.GotoManager;
    import sg.cfg.ConfigServer;
    import sg.net.NetMethodCfg;
    import sg.manager.ModelManager;
    import sg.model.ViewModelBase;
    import sg.model.ModelUser;
    // import ui.init.affiche_mainUI;

    public class ModelPayment extends ViewModelBase
    {
		public static const CLOSE_PANEL:String = "close_panel";	// 数据更新

		// 单例
		private static var sModel:ModelPayment = null;
		
		public static function get instance():ModelPayment
		{
			return sModel ||= new ModelPayment();
		}
		
        private var cfg:Object;
        private var pay_reward:Array;
        private var singleConfig:Object = null;;
        public function ModelPayment() {
                 
            // 获取配置
            this.cfg = ConfigServer.ploy['independ_pay'];
            haveConfig = Boolean(cfg);
        }

        override public function refreshData(reward:*):void {
            if (!haveConfig) return;  
            // 获取用户数据
            this.pay_reward = reward;
            singleConfig = this.cfg[this.pay_reward[0]];
            this.event(ModelActivities.UPDATE_DATA);
        }

        public function getReward():void
        {
            if (this.redPoint) {
                ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_PAY_REWARD);
                this.event(CLOSE_PANEL);
            }
            else {
                GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
            }
        }

        public function getNeedMoney():int
        {
            return this.cfg[this.pay_reward[0]]['pay_money'];
        }
        
        public function getConfig():Object {
            return this.cfg;            
        }

        public function getData():Array {
            return this.pay_reward;            
        }

		/**
		 * 是否激活
		 */
		override public function get active():Boolean {
            var delay_day:int = 0;
            var user:ModelUser = ModelManager.instance.modelUser;
            if (singleConfig && singleConfig.delay_day)
                delay_day = singleConfig.delay_day;
			return user.canPay && haveConfig && singleConfig && delay_day < user.getGameDate();
		}

		/**
		 * 是否需要显示红点
		 */
		override public function get redPoint():Boolean {
			return active && this.pay_reward[1] >= this.cfg[this.pay_reward[0]]['pay_money'];
		}
    }
}