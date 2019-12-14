package sg.activities.view
{
    import laya.events.Event;
    import laya.utils.Handler;

    import sg.activities.model.ModelOnlineReward;
    import sg.boundFor.GotoManager;
    import sg.manager.ModelManager;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;
    import ui.onlineReward.onlineRewardPanelUI;
    import sg.utils.TimeHelper;

    public class ViewOnlineRewardPanel extends onlineRewardPanelUI
    {
        private var model:ModelOnlineReward = ModelOnlineReward.instance;
        public function ViewOnlineRewardPanel()
        {
            this.btn_close.clickHandler = new Handler(this, this.closeSelf);
            this.btn_close.clickHandler = new Handler(this, this.closeSelf);
			this.rewardList.itemRender = RewardItem;
            this.rewardList.renderHandler = new Handler(this, this._updateItem);
            this.btn_reward.on(Event.CLICK, this, this._onClickReward);
            this.model.getRewardIndex() === 4 && this.closeSelf();
            this.on(Event.DISPLAY, this, this._onDisplay);
        }

        private function _onDisplay():void
        {
            this.refreshRewardList();            
        }
        
        private function _updateItem(item:RewardItem, index:int):void
        {
            item.setReward(item.dataSource);
        }

		override public function onAdded():void{
            this.model.on(ModelOnlineReward.REMOVE_SELF, this, this.closeSelf);
            this.refreshTime();
            Laya.timer.loop(1000, this, this.refreshTime);
        }

        private function refreshRewardList():void
        {
            var cfg:Object = this.model.getConfig();
            var online:Array = cfg['online'];
            var index:int = this.model.getRewardIndex();
            if (index < 4) {
                var data:Object = online[index];
                var reward:Object = ObjectUtil.mergeObjects([ObjectUtil.clone(data['reward']), data['pay_reward']]);
                this.rewardList.array = ModelManager.instance.modelProp.getRewardProp(reward);
            }
        }

        private function refreshTime():void
        {
            var cfg:Object = this.model.getConfig();
            if (model.getTime()) {
                this.tipTxt.text = TimeHelper.formatTime(model.getTime()) + Tools.getMsgById('_jia0002');
                this.btn_reward.label = Tools.getMsgById('_public104');
            }
            else {
                this.tipTxt.text = Tools.getMsgById('_jia0003');
                this.btn_reward.label = Tools.getMsgById('_public103');
            }

            if(this.model.extraRewardFlag())
            {
                this.payHint.text = Tools.getMsgById('_jia0004');
                this.extraHint.visible = false;
            }
            else
            {
                this.payHint.text = Tools.getMsgById('_jia0005', [cfg['pay_money'] * 10]);
                this.extraHint.visible = true;                
            }
        }

        private function _onClickReward(event:Event):void
        {
            if (ModelOnlineReward.haveReward()) {
                this.model.getReward();
            }
            else {
                GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
            }
        }
        
		override public function onRemoved():void 
		{
			super.onRemoved();
            Laya.timer.clear(this, this.refreshTime);
            this.model.off(ModelOnlineReward.REMOVE_SELF, this, this.closeSelf);
		}
    }
}