package sg.activities.view
{
    import ui.activities.surpriseGift.surpriseGiftBaseUI;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.activities.model.ModelSurpriseGift;
    import sg.manager.ViewManager;
    import sg.activities.model.ModelActivities;
    import laya.utils.Handler;
    import sg.model.ModelUser;

    public class SurpriseGiftBase extends surpriseGiftBaseUI
    {
        private var model:ModelSurpriseGift = ModelSurpriseGift.instance;
        public function SurpriseGiftBase() {
            txt_times_hint.text = Tools.getMsgById('surprise_06');
            btn_buy.label = Tools.getMsgById('_public44');
            btn_buy.on(Event.CLICK, this, this._onClickBuy);
        }

        private function set dataSource(source:Object):void {
            if (!source) return;
			this._dataSource = source;
            txt_name.text = Tools.getMsgById(source.name);
            txt_times.text = [source.num - source.buy_times, source.num].join('/');
            txt_tips.text = Tools.getMsgById('surprise_05', [source.worth_gold, ModelUser.getPayMoneyStr(source.money)]);
            list.data = source.reward;
            btn_buy.gray = model.notStart || source.excluded || source.buy_times >= source.num || !model.active;
        }

        private function _onClickBuy():void {
            if (_dataSource.excluded) { // 平台不支持
                ViewManager.instance.showTipsTxt(Tools.getMsgById('surprise_07'));
            }
            else if (model.notStart) { // 活动未开始
                ViewManager.instance.showTipsTxt(Tools.getMsgById('pay_rank9'));
            }
            else if (_dataSource.buy_times >= _dataSource.num) { // 无购买次数
                ViewManager.instance.showTipsTxt(Tools.getMsgById('surprise_14'));
            }
            else if (!model.active) { // 活动已结束
                ViewManager.instance.showTipsTxt(Tools.getMsgById('happy_tips07'));
            } else {
                ViewManager.instance.showHintPanel(
                    Tools.getMsgById('surprise_16'), // 内容
                    null,
                    [
                        {'name': Tools.getMsgById('surprise_17'), 'handler': Handler.create(this, function():void {model.butGoods(_dataSource.pid);})},
                        {'name': Tools.getMsgById('_shogun_text03'), 'handler': null},
                    ]
                );
            }
        }
    }
}