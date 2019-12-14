package sg.activities.view
{
    import ui.activities.payChoose.payChooseShopUI;
    import sg.activities.model.ModelpayChoose;
    import laya.events.Event;
    import sg.activities.model.ModelActivities;
    import sg.boundFor.GotoManager;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import laya.maths.Point;
    import laya.utils.Handler;
    import sg.manager.ViewManager;
    import sg.manager.ModelManager;
    import sg.model.ModelEquip;

    public class PayChooseMain extends payChooseShopUI
    {
        private var model:ModelpayChoose = ModelpayChoose.instance;
        private var _goodsIndex:int = -1;
        private var itemId:String;
        public function PayChooseMain() {
            this.list.scrollBar.hide = true;
            this.list.left = this.list.spaceX = this.list.spaceY = 8;
			this.list.itemRender = PayChooseBase;
            this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this, this._selectGoods);
            this.btn.on(Event.CLICK, this, this._onClickBtn);
            this.model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            this.on(Event.DISPLAY, this, this._onDisplay);
            hintTxt.text = Tools.getMsgById('_jia0052');
            txt_tips.text = Tools.getMsgById('502078');
            txt_alreadyPayHint.text = Tools.getMsgById('_jia0049') + ':';
            txt_canGetHint.text = Tools.getMsgById('_estate_text03', [Tools.getMsgById('_jia0006')])  + ':';
            txt_remainTimesHint.text = Tools.getMsgById('_jia0107');
            txt_needHint.text = model.cfg['need_pay_coin'];

            Tools.textLayout(hintTxt,timeTxt,timeImg);
            Tools.textLayout(txt_alreadyPayHint,payIcon,img1,box1);
            Tools.textLayout(txt_canGetHint,txt_getTimes,img2,box2);
            Tools.textLayout(txt_remainTimesHint,txt_remainTimes,img3,box3);

            box2.x = box1.x + box1.width + 30;
        }

        private function _onDisplay():void {
            Laya.timer.loop(1000, this, this.refreshtime);
            this.refreshtime();
            model.resetGoods();
            this.refreshPanel();
        }

		public function removeCostumeEvent():void {
            Laya.timer.clear(this, this.refreshtime);
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
		}

        private function refreshPanel():void {
            this.payIcon.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), model.payCoin);
            txt_getTimes.text = String(model.canGetTimes);
            txt_remainTimes.text = String(model.remainTimes);
            if (model.canGetTimes > 0) {
                this.btn.label = Tools.getMsgById('_jia0035');
                this.btn.skin = AssetsManager.getAssetsUI('btn_yes.png')
            }
            else {
                this.btn.label = Tools.getMsgById('_public104');
                this.btn.skin = AssetsManager.getAssetsUI('btn_ok.png')
            }
            list.array = model.getListData();
        }

        private function _selectGoods(index:int):void {
            _goodsIndex >= 0 && (list.array[_goodsIndex].selected = false);
            _goodsIndex = index;
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(list.array[index].reward);
            itemId = arr[0][0];
            list.array[_goodsIndex].selected = true;
            list.refresh();
        }

        private function _onClickBtn():void {
            if (model.canGetTimes > 0) {
                if (_goodsIndex === -1) {
                    ViewManager.instance.showTipsTxt(Tools.getMsgById('502064'));
                    return;
                }
                else if(model.remainTimes <= 0) {
                    ViewManager.instance.showTipsTxt(Tools.getMsgById('502065'));
                    return;
                }
                var equipModel:ModelEquip = ModelManager.instance.modelGame.getModelEquip(itemId);
                if (equipModel && equipModel.isMine()) {
                    ViewManager.instance.showTipsTxt(Tools.getMsgById('502068'));
                    return;
                }
                var cell:PayChooseBase = list.getCell(_goodsIndex) as PayChooseBase;
                var pos:Point = null;
                if (cell) { // 可能取不到
                    var rewardItem:* = cell.rewardItem;
                    pos = Point.TEMP.setTo(rewardItem.x + rewardItem.width * 0.5, rewardItem.y);
                    pos = rewardItem['parent'].localToGlobal(pos, true);
                }
                else {
                    pos = new Point(Laya.stage.width * 0.5, Laya.stage.height * 0.3)
                }
                model.buyGoods(_goodsIndex, pos);
            }
            else GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
        }

        private function refreshtime():void {
            this.timeTxt.text = model.getTimeString();
        }
    }
}