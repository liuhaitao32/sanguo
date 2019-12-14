package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelFund;
    import sg.boundFor.GotoManager;
    import sg.manager.AssetsManager;
    import sg.manager.ViewManager;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.activities.fund.fundUI;
    import sg.manager.LoadeManager;

    public class FundMain extends fundUI
    {
        private var model:ModelFund = ModelFund.instance;
        public function FundMain()
        {
            this.list.scrollBar.hide = true;
			this.list.itemRender = FundBase;
            // this.payHint.text = Tools.getMsgById('_jia0049');
            this.hintTxt.text = Tools.getMsgById('_jia0047', [model.getNeedPayNum()]);
            // this.desTxt.text = Tools.getMsgById('_jia0048', [model.getRewardData()['length'], 3600]);
            totalRewardCoin.text = model.cfg['show'];
            this.btn_preview.label = Tools.getMsgById('_public113');
            this.btn_preview.on(Event.CLICK, this, this._previewReward);
            this.btn_buy.getChildByName('label')['text'] = model.getBuyCoin();
            this.btn_pay.on(Event.CLICK, this, GotoManager.boundForPanel, [GotoManager.VIEW_PAY_TEST]);
            this.model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            LoadeManager.loadTemp(character, AssetsManager.getAssetsHero(model.cfg['image'], false));
            this.refreshPanel();
        }

        private function _previewReward():void {
            GotoManager.boundForPanel(GotoManager.VIEW_REWARD_PREVIEW, '', this.model.getTotalReward());
        }

		public function removeCostumeEvent():void {
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
		}

        private function refreshPanel():void {
            if (model.getAlreadyPayNum() >= model.getNeedPayNum()) {
                this.payIcon.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), Tools.getMsgById('_jia0143'));
            } else {
                this.payIcon.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), model.getAlreadyPayNum());
            }
            var arr:Array = ObjectUtil.clone(this.model.getListData(), true) as Array;
            arr.sort(function (a:Object, b:Object):Boolean {
                return a.index - b.index;
            });
            var tempArr:Array = [];
            for(var i:int = arr.length - 1; i >= 0; i--)
            {
                var element:Object = arr[i];
                element.model = this.model;
                if (element.state === 2) {
                    tempArr.unshift(arr.splice(i, 1)[0]);
                }
            }
            this.list.array = arr.concat(tempArr);
            if (model.isCanBuy()) {
                this.btn_buy.gray = false;
                this.btn_buy.once(Event.CLICK, this, this._onClickBuy);
            }
            else {
                this.btn_buy.gray = true;
            }
            model.active || ViewActivities.resetScene();
        }

        private function _onClickBuy():void {
            this.model.buyFund();
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_public133"));//"充值成功！"
        }
    }
}