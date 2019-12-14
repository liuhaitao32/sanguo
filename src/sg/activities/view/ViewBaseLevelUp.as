package sg.activities.view
{
    import laya.events.Event;
    import laya.utils.Handler;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelBaseLevelUp;
    import sg.guide.model.ModelGuide;
    import sg.manager.AssetsManager;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import sg.model.ModelItem;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.activities.baseLevelUpUI;
    import sg.manager.LoadeManager;

    public class ViewBaseLevelUp extends baseLevelUpUI
    {
        private var model:ModelBaseLevelUp = ModelBaseLevelUp.instance;
        private var baseGrade:String;
        public function ViewBaseLevelUp()
        {
            this.titleTxt.text = Tools.getMsgById(this.model.title);
            this.tipsTxt.text = Tools.getMsgById(this.model.tips);
            // this.tipsTxt2.text = Tools.getMsgById('502013');
            this.tipsTxt2.text = '';
			this.tabs.selectHandler = new Handler(this, this._onSelectTabs);
			this.rewardList.itemRender = RewardItem;
            this.rewardList.renderHandler = new Handler(this, this._updateItem);
            this.btn_get.on(Event.CLICK, this, this.getReward);
			this.payHintTxt.text = Tools.getMsgById("502007");
        }

        public override function onAddedBase():void
        {
            super.onAddedBase();
            LoadeManager.loadTemp(this.characterImg, AssetsManager.getAssetsHero(this.model.character, false));
            Laya.timer.frameLoop(1, this, this._onFrameChange);
            this.model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            this.refreshPanel();
            if (this.currArg) {
               this.tabs.selectedIndex = model.getLevelUpKeys().indexOf(this.currArg);
            }
            else {
               this.tabs.selectedIndex = 0;
            }
        }

        private function _onFrameChange():void
        {
            if (this.model.checkRewardActive(this.baseGrade)) {
                this.boxEffect.rotation += 0.2;
            }
            this._refreshTime();
        }

        private function refreshPanel():void
        {
            var tempKeys:Array = this.model.getLevelUpKeys();
            var keys:Array = ObjectUtil.clone(tempKeys) as Array;
            var len:int = keys.length;
            for(var i:int = 0; i < len; i++)
            {
                keys[i] += Tools.getMsgById(this.model.tab_name);
                
            }
            if (keys.length) {
                this.tabs.labels = keys.join(',');
                if (tempKeys.indexOf(this.baseGrade) === -1)    this.baseGrade = tempKeys[0];
                this.refreshChild();
                if (this.tabs.selectedIndex >= keys.length) {
                    this.tabs.selectedIndex = 0;
                }
                for (i = 0; i < len; ++i) {
                    ModelGame.redCheckOnce(this.tabs.items[i], ModelBaseLevelUp.instance.checkRewardActive(tempKeys[i]));
                }
            }
            else {
                this.closeSelf();
            }
        }

        private function _onSelectTabs(index:int):void
        {
            var keys:Array = model.getLevelUpKeys();
            if (!keys.length)   return;
            baseGrade = keys[index];
            this.refreshChild();
        }

        private function refreshChild():void
        {
            var grade:String = this.baseGrade;
            if (!grade) return;
            this.refreshRewardList();
            var active:Boolean = this.model.checkRewardActive(grade);
            var needMoneyStr:String = this.model.getNeedMoney(grade);
            this.needMoney.text = needMoneyStr;
            this.btn_get.label = Tools.getMsgById(active ? '_public103' : '_public105');
            var str:String = ModelItem.getItemIconAssetUI('coin', false);
            this.payIcon.setData(str, this.model.getCurrentMoney(grade) + '/' +needMoneyStr);
            this.endHintMc.visible = this.model.getRemainingTime(this.baseGrade) > 0;
        }

        private function refreshRewardList():void
    {
            var cfg:Object = this.model.cfg['reward'][this.baseGrade];
            this.rewardList.array = ModelManager.instance.modelProp.getRewardProp(cfg[1]);
        }

        private function _updateItem(item:RewardItem, index:int):void
        {
            item.setReward(item.dataSource);
        }

        private function _refreshTime():void
        {
            this.endHintMc.visible = this.model.getRemainingTime(this.baseGrade) > 0;
            this.endHintTxt.text = this.model.getTimeString(this.baseGrade) + Tools.getMsgById('_public107');
        }

        private function getReward():void
        {
            this.model.getReward(this.baseGrade);
        }

		override public function onRemoved():void 
		{
			super.onRemoved();
            Laya.timer.clearAll(this);
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            ModelGuide.executeGuide();
		}
    }
}