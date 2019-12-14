package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelWeekCard;
    import sg.net.NetMethodCfg;
    import sg.utils.Tools;

    import ui.activities.weekCard.weekCardRewardPanelUI;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;

    public class ViewWeekcardRewardPanel extends weekCardRewardPanelUI
    {
        private var model:ModelWeekCard = ModelWeekCard.instance;
        public function ViewWeekcardRewardPanel()
        {
            this.closehint.text = Tools.getMsgById('_public114');
        }

		override public function onAddedBase():void {
			super.onAddedBase();
            LoadeManager.loadTemp(bg, AssetsManager.getAssetsAD('actPay1_5.png'));
            this.remainDays.text = Tools.getMsgById('_jia0051', [this.model.getRemainDays() - 1]);
            this.reward.setData('coin', this.model.cfg['cycle_reward'], -1);
            this.reward.mCanClick = false;
            this.box.once(Event.CLICK, this, this.closeSelf);
		}
        
        override public function closeSelf(onlySelf:Boolean = true):void {
            this.box.off(Event.CLICK, this, this.closeSelf);
            super.closeSelf(onlySelf);
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_WEEK_CARD_GIFT);
        }
    }
}