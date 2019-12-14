package sg.activities.view
{
    import laya.events.Event;
    import laya.utils.Handler;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelPayment;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
    import sg.manager.ModelManager;
    import sg.utils.Tools;

    import ui.activities.payMentUI;

    public class ViewPayment extends payMentUI
    {
        private var model:ModelPayment = ModelPayment.instance;
        public function ViewPayment()
        {
            this.btn_close.on(Event.CLICK, this, this.closeSelf);
			this.rewardList.itemRender = RewardItem;
            this.rewardList.renderHandler = new Handler(this, this._updateItem);
            this.btn_pay.on(Event.CLICK, this.model, this.model.getReward);
            this.refreshPanel();
            this.previewTxt.text = Tools.getMsgById('_public113');
        }

        override public function onAdded():void
        {
            this.model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);    
            this.model.on(ModelPayment.CLOSE_PANEL, this, this.closeSelf); 
            this.refreshPanel();   
        }

        private function refreshPanel():void
        {
            if (model.active) {
                this.refreshRewardList();
                this.btn_pay.label = Tools.getMsgById(model.redPoint ? '_public103' : '_public104');
            }
            else {
                this.closeSelf();
            }
        }

        private function refreshRewardList():void
        {
            var cfg:Object = this.model.getConfig();
            var pay_reward:Array = this.model.getData();
            if (!cfg[pay_reward[0]]) return;
            var data:Object = cfg[pay_reward[0]];
            this.rewardList.array = ModelManager.instance.modelProp.getRewardProp(data['reward']);
            this.needMoney.text = String(this.model.getNeedMoney() * 10);
            this.pic1.skin = this.pic2.skin = this.pic3.skin = this.pic4.skin = '';
            LoadeManager.loadTemp(this.pic1, AssetsManager.getAssetsAD(data['picture'][0]));
            this.pic2.skin = AssetsManager.getAssetLater(data['picture'][1]);
            this.pic3.skin = AssetsManager.getAssetLater(data['picture'][2]);
            if (data['picture'][3]) {
                this.pic4.skin = AssetsManager.getAssetsUI(data['picture'][3]);
                this.needMoney.visible = false;
            }
            else {
                this.needMoney.visible = true;
            }            
            
        }

        private function _updateItem(item:RewardItem, index:int):void
        {
            item.setReward(item.dataSource);
        }

		override public function onRemoved():void 
		{
			super.onRemoved();
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            this.model.off(ModelPayment.CLOSE_PANEL, this, this.closeSelf);
		}
    }
}