package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelWeekCard;
    import sg.boundFor.GotoManager;
    import sg.utils.Tools;

    import ui.activities.weekCard.weekCardUI;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;

    public class WeekCardMain extends weekCardUI
    {
        private var model:ModelWeekCard = ModelWeekCard.instance;
        public function WeekCardMain()
        {
            var cfg:Object = model.cfg;
            this.btn_pay.label = Tools.getMsgById('_jia0050');
            // this.payTxt.text = cfg['pay'];
            // this.receiveTxt.text = String(cfg['pay'] * 10 + cfg['cycle'] * cfg['cycle_reward']);
            this.receiveTxt2.text = String(cfg['pay'] * 10);
            this.receiveTxt3.text = cfg['cycle_reward'];
            this.reward.setData('coin', cfg['pay'] * 10, -1);
            this.btn_pay.on(Event.CLICK, this, GotoManager.boundForPanel, [GotoManager.VIEW_PAY_TEST]);
            this.tipsTxt.text = Tools.getMsgById('502012');
            this.on(Event.DISPLAY, this, this._onDisplay);
        }

        private function _onDisplay():void
        {
            LoadeManager.loadTemp(bg, AssetsManager.getAssetsAD('actPay1_6.png'));
        }

    }
}