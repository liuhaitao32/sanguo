package sg.festival.view
{
    import ui.activities.payAgainUI;
    import sg.festival.model.ModelFestivalPayAgain;
    import sg.activities.view.RewardList;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import laya.utils.Handler;
    import laya.ui.Button;
    import laya.events.Event;
    import sg.utils.TimeHelper;
    import sg.cfg.ConfigServer;
    import sg.manager.AssetsManager;
    import sg.activities.model.ModelActivities;
    import sg.manager.LoadeManager;
    import sg.festival.model.ModelFestival;

    public class ViewFestivalPayAgain extends payAgainUI {
        private var model:ModelFestivalPayAgain = ModelFestivalPayAgain.instance;
		private var rewardList:RewardList;
        public function ViewFestivalPayAgain() {
            rewardList = new RewardList();
            rewardList.align = RewardList.ALIGN_CENTER;
            rewardList.pos(290, 75);
            box_reward.addChild(this.rewardList);
            tabList.scrollBar.hide = true;
            comTitle.setViewTitle(Tools.getMsgById('pay_again'), true);
            comHero.pos(model.cfg.hero[1][0], model.cfg.hero[1][1]);
            btn_price.on(Event.CLICK, this, this._onClickBuy);
            tabList.renderHandler = new Handler(this, this.updateTab);
        }

        override public function initData():void {
        }

        override public function onAdded():void {
            LoadeManager.loadTemp(img_bg, AssetsManager.getAssetsAD(ModelFestival.instance.actCfg.bgm));
            comHero.setHeroIcon(model.cfg.hero[0], false);
            this.refreshPanel();
            Laya.timer.loop(1000, this, this.refreshTime);
            model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
        }

        private function refreshPanel():void {
            var tabData:Array = model.tabData;
            if (tabData.length === 0) {
                this.closeSelf();
            }
            tabList.array = tabData;
            tabList.selectedIndex = 0;
            tabList.visible = tabData.length > 1;
            this.refreshTime();
        }

        private function refreshTime():void {
            var data:Object = tabList.selectedItem;
            if (data) {
                txt_time.text = TimeHelper.formatTime(data.endTime - ConfigServer.getServerTimer()) + Tools.getMsgById('_public107');
            }
        }

        private function updateTab(btn:Button, index:int):void {
            var data:Object = btn.dataSource;
            var labelName:String = Tools.getMsgById('550066', [data.money]);
            btn.label = labelName;
            btn.off(Event.CLICK, this, this._onClickTab);
            if (tabList.selectedIndex === index) {
                btn.selected = true;
                this.refreshTime();
                btn_price.setDoubleTxt(data.oriPrice, data.price, 'coin');
                txt_tips.text = Tools.getMsgById(model.cfg.info);
                txt_tips2.visible = model.cfg.reward[data.money][3] <= 10;
                txt_tips2.text = Tools.getMsgById(model.cfg.info2 , [model.remainTimes(data.money)]);
                rewardList.setArray(ModelManager.instance.modelProp.getRewardProp(data.reward));
            } else {
                btn.selected = false;
                btn.on(Event.CLICK, this, this._onClickTab, [index]);
            }
        }

        private function _onClickTab(index:int, event:Event):void {
            var btn:Button = event.currentTarget as Button;
            tabList.selectedIndex = index;
        }

        private function _onClickBuy():void {
            var btn:Button = event.currentTarget as Button;
            model.getReward(tabList.selectedItem.index);
        }
        
		override public function onRemoved():void {
			model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            Laya.timer.clear(this, this.refreshTime);
			super.onRemoved();
		}
    }
}