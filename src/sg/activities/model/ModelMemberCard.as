package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.net.NetMethodCfg;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import sg.utils.ArrayUtil;

    public class ModelMemberCard extends ViewModelBase {

		// 单例
		private static var sModel:ModelMemberCard = null;
		
		public static function get instance():ModelMemberCard {
			return sModel ||= new ModelMemberCard();
		}
		
        public var cfg:Object;
        public var needPop:Boolean = false; // 是否需要弹板
        public var pid:String = '';
        private var member:Array;
        public function ModelMemberCard() {

            // 获取配置
            this.cfg = ConfigServer.ploy.member_card;
            haveConfig = Boolean(cfg);
            var user:ModelUser = ModelManager.instance.modelUser;
            member = user.member || [0, null];
            pid = ModelUser.getPidByMoney(cfg.pay);
            needPop = pid && member[0] && member[1] !== user.getGameDate();
        }

        /**
         * 数据更新
         */
        override public function refreshData(data:*):void {
            if (!data is Array || !haveConfig) return;
            // data[0] > member[0] && this.getReward(); // 购买后立即领奖(改成后端推送了)
            member = data; // 刷新数据
            ModelActivities.instance.event(ModelActivities.REFRESH_TAB);
        }

        /**
         * 领奖
         */
        public function getReward():void {
            this.sendMethod(NetMethodCfg.WS_SR_GET_MEMBER_CARD_REWARD);
        }

        override public function get active():Boolean {
            var user:ModelUser = ModelManager.instance.modelUser;
            return user.canPay && haveConfig && pid && member[0] === 0 && (user.member_check || user.records.pay_money >= cfg.show_pay);
        }

        override public function get redPoint():Boolean {
            return member[0] === 0 && ModelManager.instance.modelUser.member_check;
        }
    }
}