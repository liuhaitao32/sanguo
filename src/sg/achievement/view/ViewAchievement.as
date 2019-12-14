package sg.achievement.view
{
    import laya.ui.Box;
    import laya.utils.Handler;

    import sg.achievement.model.ModelAchievement;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;

    import ui.inside.achievement_mainUI;

    public class ViewAchievement extends achievement_mainUI
    {
        private var modelAchieve:ModelAchievement = ModelAchievement.instance;
        private var tabIndex:int = -1;
        public function ViewAchievement()
        {            
            this.tabList.array = this.modelAchieve.getTabLabels();
            this.tabList.scrollBar.hide = true;
            this.tabList.renderHandler = new Handler(this, this._updateTab);
            this.tabList.selectEnable = true;
            this.tabList.selectHandler = new Handler(this, this.tab_select);
			this.achieveList.itemRender = ViewAchievementBase;
			this.achieveList.scrollBar.hide = true;
			this.modelAchieve.on(ModelAchievement.UPDATE_DATA, this, this._onUpdateData);
            this.mcComplete.setData(AssetsManager.getAssetsUI('icon_paopao33.png'), 0);
            this.tipsTxt.text = Tools.getMsgById('_jia0022');
        }

        private function _updateTab(item:Box, index:int):void
        {
            var source:* = item.dataSource;
            item.hitTestPrior = true;
            item.getChildByName('title')['text'] = source.name;
            item.getChildByName('tagIcon')['visible'] = source.flag;
            item.getChildByName('progressTxt')['text'] = '(' + source.progress + ')';
        }

        override public function set currArg(v:*):void {
			this.mCurrArg = v;
            this.tab_select(v is Number ? v : 0);
		}

        override public function initData():void{
            this.setTitle(Tools.getMsgById('_jia0015'));
        }

        private function tab_select(index:int):void {
            this.tabIndex = index;
            this.achieveList.array = this.modelAchieve.getEffortsByIndex(index) as Array;
            this.achieveList.scrollTo(0);
            this._onUpdateData();
            this.mc_tips.visible = (index === 3 && this.achieveList.array.length === 0);
        }

        private function _onUpdateData():void {
            var len:int = this.modelAchieve.getTabLabels().length;
            var tempArray:Array = null;
            var totalProgress:int = 0;
            for(var index:int = 0; index < len; index++)
            {
                tempArray = this.modelAchieve.getEffortsByIndex(index);
                var len2:int = tempArray.length;
                for(var i:int = 0; i < len2; i++)
                {
                    var data:Object = tempArray[i];
                    var cfg:Object = this.modelAchieve.getEffortConfigById(data['id']);
                    data.state !== 0 && (totalProgress += parseInt(cfg.score));
                }
            }
            this.mcComplete.setNum(totalProgress);
            this.tabList.refresh();
			this.achieveList.refresh();            
        }

        override public function onRemoved():void{
            this.tabList.selectedIndex = -1;
        }
    }
}