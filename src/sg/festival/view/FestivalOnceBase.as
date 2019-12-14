package sg.festival.view
{
    import ui.festival.festival_once_baseUI;
    import ui.bag.bagItemUI;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.boundFor.GotoManager;
    import sg.festival.model.ModelFestivalOnce;

    public class FestivalOnceBase extends festival_once_baseUI
    {
        public function FestivalOnceBase()
        {
            list.itemRender = bagItemUI;
            btn_get.on(Event.CLICK, this, this._onClickGet);
        }

        private function set dataSource(value:Object):void {
            if (!value) return;
			this._dataSource = value;
            list.array = value.reward;
            needPayTxt.text = value.need_num;
            btn_get.gray = value.complete;
            var reward_num:Array = value.reward_num;
            btn_get.label = Tools.getMsgById('_public138') + (value.can_get_num ? ('(' + value.can_get_num  + ')') : '');
            Tools.textFitFontSize(btn_get);
            btn_get.gray = !Boolean(value.can_get_num);
            txt_tips.text = Tools.getMsgById('_jia0139', [value.limit_num - reward_num[0], value.limit_num]);
            Tools.textFitFontSize(txt_tips);
        }
        private function _onClickGet():void {
            if (_dataSource.can_get_num) {
                ModelFestivalOnce.instance.getReward(_dataSource.key);
            } else {
                GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
            }
        }
    }
}