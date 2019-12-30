package sg.activities.view
{
    import laya.events.Event;
    import laya.maths.Point;
    import ui.activities.exchange.exchangeTabBaseUI;
    import sg.model.ModelGame;
    import laya.utils.Handler;
    import laya.display.Sprite;

    public class ExchangeTabBase extends exchangeTabBaseUI
    {
        private var rewardItemArr:Array = [];
        private var itemId:String;
        public function ExchangeTabBase() {
            btn.disabled = true;
            btn.label = '';
            this.on(Event.CLICK, this, this._onClick);
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            icon.setData(source.itemId, -1, -1);
            (icon.getChildByName('bg') as Sprite).visible = false;
            (icon.getChildByName('imgBG') as Sprite).visible = false;
            icon.clearEvents();
            btn.gray = icon.gray = icon_lock.visible = source.locked;
            txt_num.text = source.num;
            txt_name.text = source.name;
            txt_name.color = txt_num.color = source.selected ? "#fdffbf": "#d2eaff";
            btn.selected = source.selected;
            this.alpha = source.selected || source.locked ? 1 : 0.7;
            ModelGame.redCheckOnce(this, source.red);
        }

        private function _onClick():void {
            var handler:Handler = _dataSource.handler;
            _dataSource.locked || handler.runWith(_dataSource.index);
        }
    }
}