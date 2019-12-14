package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelMemberCard;
    import sg.net.NetMethodCfg;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import ui.activities.memberCard.memberCardRewardPanelUI;
    import sg.manager.ViewManager;
    import ui.bag.bagItemUI;
    import sg.manager.ModelManager;
    import sg.manager.LoadeManager;

    public class ViewMemberRewardPanel extends memberCardRewardPanelUI
    {
        private var model:ModelMemberCard = ModelMemberCard.instance;
        public function ViewMemberRewardPanel()
        {
            list.itemRender = bagItemUI;
            btn_get.label = Tools.getMsgById('member_06');
            btn_get.on(Event.CLICK, this, this._onClickGet);
            btn_help.on(Event.CLICK, this, this._onClickHelp);
        }

		override public function onAddedBase():void {
			super.onAddedBase();
            this.isAutoClose = false;
            LoadeManager.loadTemp(bg, AssetsManager.getAssetsAD('actPay1_5_1.png'));
            var day_reward:Array = ModelManager.instance.modelProp.getRewardProp(model.cfg.day_reward);
            list.array = day_reward.map(function(arr:Array):Array {
                return [arr[0], arr[1], -1];
            }, this);
		}
        
        private function _onClickGet():void {
            model.getReward();
            ViewManager.instance.closePanel(this);
        }
        
        private function _onClickHelp():void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(model.cfg.help_info));
        }
    }
}