package sg.explore.view
{
    import ui.explore.chooseHeroUI;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.view.fight.ItemTroop;
    import sg.model.ModelHero;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;

    public class ViewChangeHero extends chooseHeroUI
    {
        private var handler:Handler;
        private var filterHeros:Array; // 需要过滤掉的英雄
        private var currentIndex:int = 0;
        private var dataArr:Array; // 需要过滤掉的英雄
        public function ViewChangeHero()
        {
            list.itemRender = ItemTroop;
            list.selectEnable = true;
            list.selectHandler = new Handler(this,this.list_select);
            list.scrollBar.hide = true;
            btn.on(Event.CLICK,this,this._onClickBtn);
            txt_hint.text = ''; // 备用提示
        }

        override public function initData():void {
            handler = currArg.handler;
            filterHeros = currArg.filterHeros;
            btn.label=Tools.getMsgById('_public51');
            comTitle.setViewTitle(Tools.getMsgById('_climb14'));
            
            var heroArr:Array = ModelManager.instance.modelUser.getMyHeroArr(true, "", null, true);
            if (filterHeros is Array) heroArr = heroArr.filter(function(item:Object):Boolean {return filterHeros.indexOf(item.id) === -1}, this);
            dataArr = heroArr.map(function(md:*):Object { return {md:md, selected:false}; }, this);
            if (dataArr.length) {
                list.array = dataArr;
            } else {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0136'));
                this.closeSelf();
            }
        }
        
        override public function onAddedBase():void {
            super.onAddedBase();
            list.scrollTo(0);
            list.selectedIndex = 0;
            this.list_select(0);
        }

        private function list_select(index:int):void {
            dataArr[currentIndex].selected = false;
            dataArr[index].selected = true;
            currentIndex = index;
        }
        
        private function _onClickBtn():void {
            if (handler) {
                handler.runWith(dataArr[currentIndex].md.id);
            }
            this.closeSelf();
        } 
    }
}