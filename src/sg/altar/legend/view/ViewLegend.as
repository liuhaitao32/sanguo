package sg.altar.legend.view
{
    import ui.fight.legendMainUI;
    import sg.cfg.ConfigServer;
    import sg.altar.legend.model.ModelLegend;
    import laya.events.Event;
    import sg.utils.Tools;
    import sg.manager.ViewManager;
    import laya.utils.Handler;

    public class ViewLegend extends legendMainUI
    {
        public var model:ModelLegend = ModelLegend.instance;
        public function ViewLegend() {
            list.itemRender = LegendBase;
            list.scrollBar.hide = true;
            txt_hint.text = Tools.getMsgById('_pk05');
            btn_add.on(Event.CLICK, this, this._onClickAdd);
        }

        override public function initData():void {
            model.on(ModelLegend.UPDATE_DATA, this, this.refreshPanel);
        }

        override public function onAdded():void {
			this.setTitle(Tools.getMsgById('_jia0118'));
            this.refreshPanel();
        }

        public function refreshPanel():void {
            txt_num.text = model.remainTimesTxt;
            list.array = model.listData;
        }

        override public function onRemoved():void {
            model.off(ModelLegend.UPDATE_DATA, this, this.refreshPanel);
        }

        private function _onClickAdd():void {
            var price:int = model.buyPrice;
            if (price) {
                ViewManager.instance.showAlert(Tools.getMsgById("legend3", [1, Tools.getMsgById('_public146')]), Handler.create(model, model.buyChallengeTimes), ['coin', model.buyPrice]); // 购买次数
            }
            else {
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public63"));
            }
        }
    }
}