package sg.view.map
{
	import sg.cfg.ConfigServer;
    import laya.events.Event;
    import laya.ui.Button;
    import laya.utils.Handler;
    import sg.utils.Tools;
    import ui.init.troopHintUI;
    import sg.manager.AssetsManager;
    import laya.ui.Box;

    public class ViewTroopCoinFill extends troopHintUI
    {
        private var _price:int = 0;
        public function ViewTroopCoinFill()
        {
            com_title.setViewTitle(Tools.getMsgById("_jia0082"));
            btn_train.label = Tools.getMsgById('_jia0083');
            btn_fill.label = Tools.getMsgById('troopEditBtn_coin_fill_troop');
            txt_cost_hint.text = Tools.getMsgById('_jia0115');
            txt_info_hint.text = Tools.getMsgById('_public226');
        }
		override public function initData():void {
            _price = currArg['price'];
            var handlers:Array = currArg['handlers'];
            var content:String = currArg['content'];
            txt_content.text = content;
            var type:String = ConfigServer.system_simple.fast_train_type;
            icon_cost.setData(AssetsManager.getAssetItemOrPayByID(type), _price);
            this._setHandlers(handlers);
        }

        private function _setHandlers(handlers:Array):void {
            btn_fill.clearEvents();
            btn_train.clearEvents();
            btn_train.once(Event.CLICK, this, this._onClickButton, [handlers[0]]);
            if (handlers.length < 2 || !_price) {
                box_cost.visible = btn_fill.visible = txt_info_hint.visible = false;
                btn_train.x = ((btn_train.parent as Box).width - btn_train.width) * 0.5;
            }
            else {
                box_cost.visible = btn_fill.visible = txt_info_hint.visible = true;
                btn_fill.once(Event.CLICK, this, this._onClickButton, [handlers[1]]);
                btn_train.x = ((btn_train.parent as Box).width - btn_train.width - 30);
            }
        }

        private function _onClickButton(handler:Handler):void {
            this.closeSelf();
            handler is Handler && handler.run();
        }
    }
}