package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelSaleShop;
    import sg.boundFor.GotoManager;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;

    import ui.activities.saleShop.saleShopUI;

    public class SaleShopMain extends saleShopUI
    {
        private var model:ModelSaleShop = ModelSaleShop.instance;
        public function SaleShopMain()
        {
            this.list.scrollBar.hide = true;
            this.list.left = this.list.spaceX = this.list.spaceY = 8;
			this.list.itemRender = SaleShopBase;
            this.btn_pay.label = Tools.getMsgById('_public104');
            this.btn_pay.on(Event.CLICK, this, GotoManager.boundForPanel, [GotoManager.VIEW_PAY_TEST]);
            this.model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            this.on(Event.DISPLAY, this, this._onDisplay);
        }

        private function _onDisplay():void {
            Laya.timer.loop(1000, this, this.refreshtime);
            this.refreshtime();
            this.refreshPanel();
        }

		public function removeCostumeEvent():void {
            Laya.timer.clear(this, this.refreshtime);
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
		}

        private function refreshPanel():void {
            this.payIcon.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), model.getAlreadyPayNum() * 10);
            this.list.array = this.model.getListData();
        }

        private function refreshtime():void {
            this.hintTxt.text = Tools.getMsgById(model.checkStart() ? '_jia0052' : '_jia0056');
            this.timeTxt.text = model.getRemainingTime();
            Tools.textLayout(this.hintTxt,this.timeTxt,this.timeImg);
        }
    }
}