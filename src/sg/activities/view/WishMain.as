package sg.activities.view
{
    import laya.events.Event;
    import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelWish;
    import sg.boundFor.GotoManager;
    import sg.cfg.ConfigClass;
    import sg.manager.ViewManager;
    import sg.utils.Tools;

    import ui.activities.wish.wish_mainUI;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;

    public class WishMain extends wish_mainUI
    {
        private var model:ModelWish = ModelWish.instance;
        public function WishMain() {
            this._initPanel();
            Tools.textLayout(this.daysHint,this.daysTxt,this.dayImg,this.daysBox);
        }

        private function _initPanel():void
        {
            this.wishHintWords.visible = false;
            this.btn_reward.on(Event.CLICK, this, this._onClickRewardBtn);
			this.comBox.on(Event.CLICK, this, this._onClickRewardBtn);
            //this.rewardBox.on(Event.CLICK, this, this._onClickRewardBtn);
			this.rewardList.itemRender = RewardItem;
            this.rewardList.renderHandler = new Handler(this, this._updateItem);
            this.refreshPanel();
            this.model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            this.model.on(ModelWish.MAKE_WISH, this, this._onMakeWish);
            this.on(Event.DISPLAY, this, this._onDisplay);
            this.wishTips.text = Tools.getMsgById('_jia0007');
            this.daysHint.text = Tools.getMsgById('_jia0009');
            this.wishHintWords.text = Tools.getMsgById('_jia0008');
            this.payHint.text = Tools.getMsgById('_jia0010');
            this.refreshTips.text = Tools.getMsgById('_jia0011');
        }

        private function _onDisplay():void {
            var cfg:Object = this.model.getConfig();
            LoadeManager.loadTemp(character, AssetsManager.getAssetsHero(cfg.hero_icon, false));
        }

        private function _updateItem(item:RewardItem, index:int):void {
            item.dataSource && item.setReward(item.dataSource, this.model.isDouble());
        }

        private function _onMakeWish():void
        {
            var len:int = this.rewardList.array.length
            for(var i:int = 0; i < len; i++)
            {
                var cell:RewardItem = this.rewardList.getCell(i) as RewardItem;
                cell.showConfirmEffect();
            }
        }

        private function _onClickRewardBtn(event: Event):void
        {
            if(event.currentTarget === this.btn_reward)
            {
                if (this.model.wishState === 0) {
                    this.model.getReward();
                }
                else if(this.model.wishState === 1) {
                    ViewManager.instance.showView(ConfigClass.WISH_CHOOSE_PANEL);
                }
                else {
                    GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
                }
            }
            else if (event.currentTarget === this.comBox) {
                if (this.model.checkLoginReward()) {
                    this.model.getReward2();
                }
                else {
                    GotoManager.boundForPanel(GotoManager.VIEW_REWARD_PREVIEW, '', this.model.getLoginRewardList());
                }
            }
        }

        private function refreshPanel():void
        {
            var rewardArr:Array = this.model.getRewardArray();
            this.btn_reward.label = [Tools.getMsgById('_public103'), Tools.getMsgById('_jia0039'), Tools.getMsgById('_public104')][this.model.wishState];
            this.rewardList.array = rewardArr;
            this.rewardList.centerX = this.rewardList.width / 8 * (4 - rewardArr.length);
            this.rewardList.visible = this.model.wishState !== 1;
            this.wishHintWords.visible = this.model.wishState === 1;
            payHint.visible = ModelManager.instance.modelUser.canPay;
            btn_reward.visible = model.wishState !== 2 || ModelManager.instance.modelUser.canPay;
            this.daysTxt.text = model.getLoginDays() + '/' + ConfigServer.ploy.act_wish.wish_days;
			this.comBox.setRewardBox(this.model.checkLoginReward()?1:0);
        }

		public function removeCostumeEvent():void
		{
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
			this.model.off(ModelWish.MAKE_WISH, this, this._onMakeWish);
		}
    }
}