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
    import sg.model.ModelGame;

    public class ViewFestival extends festivalPanelUI
    {
        private var mFuncPanel:ItemBase;
        private var model:ModelFestival = ModelFestival.instance;
        private var tabData:Array;
        public function ViewFestival()
        {
			tabList.itemRender = FestivalTabButton;
            tabList.selectEnable = true;
            tabList.scrollBar.hide = true;
            tabList.selectHandler = new Handler(this, this.tab_select);
            tabList.scrollBar.changeHandler = new Handler(this, this._onTabScroll);
            tabList.on(Event.MOUSE_UP, this, this._checkArrowRed);
            tabList.on(Event.MOUSE_OUT, this, this._checkArrowRed);
            btn_close.on(Event.CLICK, this, this.closeSelf);
        }

        /**
         * 设置箭头是否显示
         */
        private function _onTabScroll():void {
            var v:Number = tabList.scrollBar.value;
            var max:Number = tabList.scrollBar.max;
            arrow_l.visible = v !== 0;
            arrow_r.visible = v !== max;
        }

        /**
         * 红点检测
         */
        private function _checkArrowRed():void
        {
            var v:Number = tabList.scrollBar.value;
            var w:Number = tabList.cells[0].width;
            var spaceX:Number = tabList.spaceX;

            // 左侧未显示的个数
            var num_l:int = Math.floor((v + spaceX) / (w + spaceX));
            var start_r:int = Math.floor((v + tabList.width + spaceX) / (w + spaceX));
            var flag_l:Boolean = false;
            var flag_r:Boolean = false;
            for(var i:int = 0, len:int = tabData.length; i < len; i++) {
                var element:Object = tabData[i];
                if (i < num_l) {
                    flag_l = flag_l || element.red;
                }
                else if (i >= start_r) {
                    flag_r = flag_r || element.red;
                }
            }
            ModelGame.redCheckOnce(arrow_l, flag_l);
            ModelGame.redCheckOnce(arrow_r, flag_r);
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
            if (tabData.length > 5) {
                tabBox.x = mBox.x + arrow_l.width;
                tabBox.width = tabList.width = mBox.width - arrow_l.width * 2;
            } else {
                tabList.width = tabList.getCell(0).width * tabList.repeatX + tabList.spaceX * (tabList.repeatX - 1);
            }
            tabList.selectedIndex = 0;
            model.on(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            model.on(ModelFestival.CLOSE_ENTRANCE, this, this.closeSelf);
        }

        override public function onAdded():void {
            LoadeManager.loadTemp(img_bg, AssetsManager.getAssetsAD(model.actCfg.bgm));
            this.refreshTime();
            Laya.timer.loop(1000, this, this.refreshTime);
            Laya.timer.once(50, this, function ():void {
                this._onTabScroll();
                this._checkArrowRed();
            });
        }

        private function refreshTime():void
        {
            txt_end_time.text = model.remainTime + Tools.getMsgById('_public107');
            Tools.textFitFontSize(txt_end_time);
        }

        /**
         * 刷新界面，主要是检查红点
         */
        private function refreshPanel():void {
            tabData.forEach(function(item:Object):void { item.red = this.model.redCheck(item.id); }, this);
            tabList.repeatX = Math.min(tabData.length, 5);
            tabList.array = tabData;
            tabList.scrollTo(tabList.selectedIndex);
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
            switch(type) {
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
                case ModelFestival.TYPE_DIAL:
                    this.mFuncPanel = new FestivalDial();
                    break;
                case ModelFestival.TYPE_TREASURE:
                    this.mFuncPanel = new FestivalTreasure();
                    break;
                default:
                    break;
            }
            if(this.mFuncPanel){
                this.mBox.addChild(this.mFuncPanel as Node);
                mFuncPanel.scale(mBox.width / mFuncPanel.width, mBox.height / mFuncPanel.height);
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