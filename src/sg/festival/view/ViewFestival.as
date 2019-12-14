package sg.festival.view
{
    import laya.utils.Handler;
    import laya.ui.Box;
    import sg.festival.model.ModelFestival;
    import sg.view.com.ItemBase;
    import sg.utils.Tools;
    import ui.festival.festivalPanelUI;
    import laya.display.Node;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
    import laya.events.Event;
    import sg.cfg.ConfigServer;
    import sg.utils.TimeHelper;

    public class ViewFestival extends festivalPanelUI
    {
        private var mFuncPanel:ItemBase;
        private var model:ModelFestival = ModelFestival.instance;
        private var tabData:Array;
        public function ViewFestival()
        {
			tabList.itemRender = FestivalTabButton;
            tabList.selectEnable = true;
            tabList.selectHandler = new Handler(this, this.tab_select);
            btn_close.on(Event.CLICK, this, this.closeSelf);
        }

        override public function set currArg(v:*):void {
			this.mCurrArg = v;
		}

        override public function initData():void {
            com_title.text = Tools.getMsgById('act_festival_name');
            Tools.textFitFontSize(com_title);
            var act:Object = model.actCfg.act;
            tabData = model.getActTabData();
            this.refreshPanel();
            tabList.width = tabList.getCell(0).width * tabData.length + tabList.spaceX * (tabData.length - 1);
            tabList.selectedIndex = 0;
            model.on(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            model.on(ModelFestival.CLOSE_ENTRANCE, this, this.closeSelf);
        }

        override public function onAdded():void {
            LoadeManager.loadTemp(img_bg, AssetsManager.getAssetsAD(model.actCfg.bgm));
            this.refreshTime();
            Laya.timer.loop(1000, this, this.refreshTime);
        }

        private function refreshTime():void
        {
            txt_end_time.text = TimeHelper.formatTime(model.endTime - ConfigServer.getServerTimer()) + Tools.getMsgById('_public107');
            Tools.textFitFontSize(txt_end_time);
        }

        /**
         * 刷新界面，主要是检查红点
         */
        private function refreshPanel():void {
            tabData.forEach(function(item:Object):void { item.red = this.model.redCheck(item.id); }, this);
            tabList.repeatX = tabData.length;
            tabList.array = tabData;
        }

        override public function onRemoved():void {
            model.off(ModelFestival.CLOSE_ENTRANCE, this, this.closeSelf);
            model.off(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            Laya.timer.clear(this, this.refreshTime);
            this.tabList.selectedIndex = -1;
        }

        private function tab_select(index:int):void {
            if (index === -1 || tabData.length === 0)   return;
            tabData.forEach(function(item:Object):void { item.selected = false; });
            tabData[index].selected = true;
            tabList.array = tabData;
            
            this.clearFuncPanel();
            var type:String = tabData[index].id;
            switch(type)
            {
                case ModelFestival.TYPE_LOGIN:
                    this.mFuncPanel = new FestivalLogin();
                    break;
                case ModelFestival.TYPE_ONCE:
                    this.mFuncPanel = new FestivalOnce();
                    break;
                case ModelFestival.TYPE_ADD_UP:
                    this.mFuncPanel = new FestivalAddUp();
                    break;
                case ModelFestival.TYPE_PIT_UP:
                    this.mFuncPanel = new FestivalPitUp();
                    break;
                case ModelFestival.TYPE_LUCK_SHOP:
                    this.mFuncPanel = new FestivalLuckShop();
                    break;
                case ModelFestival.TYPE_EXCHANGE:
                    this.mFuncPanel = new FestivalExchange();
                    break;
                default:
                    break;
            }
            if(this.mFuncPanel){
                this.mBox.addChild(this.mFuncPanel as Node);
                tabList.zOrder = mFuncPanel.zOrder + 1;
            }
        }

        private function clearFuncPanel():void{
            if (this.mFuncPanel is ItemBase) {
                this.mFuncPanel['removeCostumeEvent'] && this.mFuncPanel['removeCostumeEvent']();
                this.mFuncPanel.removeSelf();
                this.mFuncPanel = null;
            }
        }
    }
}