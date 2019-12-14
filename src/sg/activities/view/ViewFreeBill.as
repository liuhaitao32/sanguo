package sg.activities.view
{
    import laya.display.Sprite;
    import laya.events.Event;
    import laya.utils.Handler;
	import sg.view.com.ComPayType;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelFreeBill;
    import sg.cfg.ConfigClass;
    import sg.manager.ViewManager;
    import sg.utils.Tools;

    import ui.activities.freeBill.freeBillUI;

    public class ViewFreeBill extends freeBillUI
    {
        private var model:ModelFreeBill = ModelFreeBill.instance;
        public function ViewFreeBill()
        {
            // list.scrollBar.hide = true;
			list.itemRender = FreeBillListBase;
            rewardList.array = model.getRewardData();
            rewardList.renderHandler = new Handler(this, this._updateRewardItem);
            btn_record.label = Tools.getMsgById('_jia0063');
            btn_buy.on(Event.CLICK, this, this._buyTimes);
            btn_record.on(Event.CLICK, this, this.showRecord);
            btn_help.on(Event.CLICK, this, this.showHelp);
        }

        override public function onAdded():void
        {
            if (model.active) {
                super.onAdded();
            }
            else {
                this.closeSelf();
                ViewManager.instance.showTipsTxt(Tools.getMsgById('happy_tips07'));
            }
		}

        override public function onAddedBase():void
        {
            super.onAddedBase();
            model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            Laya.timer.loop(1000, this, this.refreshtime);
            this.refreshtime();
            this.refreshPanel();
        }

        override public function onRemovedBase():void
        {
            super.onRemovedBase();
            Laya.timer.clear(this, this.refreshtime);
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
		}

        private function refreshPanel():void {
            if (!model.active) {
                this.closeSelf();
                return;
            }
            rewardList.refresh();
            this.txt_hint2.text = Tools.getMsgById('_jia0068', [model.limitNum]);
            this.txt_hint2.width = this.txt_hint2.textField.textWidth;
            this.btn_buy.x = this.txt_hint2.x + this.txt_hint2.width + 6;
            this.list.array = model.listData;
        }

        private function refreshtime():void {
            txt_hint1.text = Tools.getMsgById(model.checkStart() ? '_jia0052' : '_jia0056');
            this.timeTxt.text = model.getRemainingTime();
            Tools.textLayout(txt_hint1,timeTxt,timeImg);
        }

        private function _updateRewardItem(item:Object, index:int):void
        {
            var source:Object = item.dataSource;
            var currentNum:int = model.getBuyGooodsTimes();
            var needNum:int = source.needNum;
            currentNum = currentNum > needNum ? needNum : currentNum;
			var comBox:ComPayType = item.getChildByName('comBox');
			comBox.off(Event.CLICK, this, this._onClickReward);
            item.getChildByName('txt').text = Tools.getMsgById('_jia0070', [currentNum, needNum]);
			var boxType:int = 0;
            if (model.rewardList.indexOf(needNum) === -1) {
				if (currentNum >= needNum) {
					boxType = 1;
				}
				comBox.on(Event.CLICK, this, this._onClickReward, [needNum]);
            }
            else {
				boxType = 2;
            }
			comBox.setRewardBox(boxType);
        }

        private function _onClickReward(needNum:int, event:Event):void
        {
            var currentNum:int = model.getBuyGooodsTimes();
            if (currentNum >= needNum) {
                model.getReward(needNum);
            }
            else {
                // 预览奖励
                var reward:Object = model.getGoods()['count_reward'][needNum];
                ViewManager.instance.showRewardPanel(reward, null, true);
            }
        }

        private function _buyTimes():void
        {
            if (model.actState === 2) {
                // 活动已结束
                ViewManager.instance.showTipsTxt(Tools.getMsgById('happy_tips07'));
            }
            else if (model.limitNum) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0071'));
            }
            else if (model.remainTimes <= 0) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_public46'));
            }
            else {
                ViewManager.instance.showBuyTimes(4, model.all_limit, model.remainTimes, model.timesPrice);
            }
        }

        private function showRecord():void
        {
            if (model.freeList.length) {
                ViewManager.instance.showView(ConfigClass.VIEW_FREE_BILL_Record);
            }
            else {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0069'));
            }
        }

        private function showHelp():void
        {
            ViewManager.instance.showTipsPanel(Tools.getMsgById('_jia0072', model.getBeginTimes()));
        }
    }
}