package sg.view.fight
{
    import ui.fight.championRankUI;
    import ui.fight.itemChampionAwardUI;
    import laya.utils.Handler;
    import sg.model.ModelClimb;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import ui.bag.bagItemUI;
    import sg.model.ModelItem;
    import sg.cfg.ConfigServer;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.model.ModelHero;
    import sg.fight.logic.utils.PassiveStrUtils;
    import sg.utils.StringUtil;

    public class ViewChampionRank extends championRankUI{
        public function ViewChampionRank(){
            this.list.itemRender = itemChampionAwardUI;
            this.list.scrollBar.hide = true;
            this.list.renderHandler = new Handler(this,this.list_render);
            //
            this.btnHelp.on(Event.CLICK,this,this.click_help);
            this.comTitle.setViewTitle(Tools.getMsgById("_climb23"));
        }
        private function click_help():void
        {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.pk_yard.pk_reward_info),500);
        }
        override public function initData():void{
            this.list.dataSource = ModelClimb.formatRankAward();
        }
        private function list_render(item:itemChampionAwardUI,index:int):void{
            var data:Array = this.list.array[index];
            var arr:Array = Tools.getPayItemArr(data[1]);
            // trace(data);
            item.rankIcon.setRankIndex(index+1,"",true);
            // item.tTitle.text = Tools.getMsgById(data[0][0]);
            item.titleIcon.setHeroTitle(data[0][0]);
            item.awardBox.destroyChildren();
            var len:int = arr.length;
            var icon:bagItemUI;
            for(var i:int = 0; i < len; i++)
            {
                icon = new bagItemUI();
                icon.setData(arr[i].id,arr[i].data);
                icon.setName("");
                //icon.setIcon(ModelItem.getItemIcon(arr[i].id));
                //icon.setNum(arr[i].data);
                icon.scale(0.6,0.6);
                icon.x = i*(icon.width*0.5+10);
                item.awardBox.addChild(icon);
            }
            item.awardBox.right = 5;
            item.awardBox.centerY = 0;
            item.titleIcon.offAll(Event.CLICK);
            
            var s:String = data[0].length == 1 ? data[0][0] : data[0][0]+"_0";
            item.titleIcon.on(Event.CLICK,this,this.click,[s]);
        }
        private function click(tid:String):void
        {
            ViewManager.instance.showItemTips(tid);
        }
    }   
}