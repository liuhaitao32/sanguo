package sg.view.fight
{
    import ui.fight.championTroopUI;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import ui.com.hero_awardUI;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ViewManager;
    import sg.utils.Tools;

    public class ViewChampionTroop extends championTroopUI{
        //
        private var mSelected:ModelHero;
        //
        private var mArr:Array;
        //
        private var mIndexCurr:int;
        //
        private var mUpdate:Handler;
        //
        public function ViewChampionTroop(){
            this.list.itemRender = ItemTroop;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.scrollBar.hide = true;
            //
            this.btn.on(Event.CLICK,this,this.click);
            this.btn.label = Tools.getMsgById('_public183');
        }
        override public function initData():void{
            //this.tTitle.text = Tools.getMsgById("_lht41");
            this.comTitle.setViewTitle(Tools.getMsgById("_lht41"));
            this.mSelected = this.currArg[0];
            this.mArr = this.currArg[1];
            this.mIndexCurr = this.currArg[2];
            this.mUpdate = this.currArg[3];
            //
            var myHeroArr:Array = ModelManager.instance.modelUser.getMyHeroArr(true,this.mSelected?this.mSelected.id:"",null,true);
            //
            this.list.selectHandler = new Handler(this,this.list_select);            
            this.list.dataSource = myHeroArr;
        }
        override public function onRemoved():void{
            this.list.selectHandler.clear();       
            this.list.selectedIndex = -1;
            this.mUpdate = null;
        }
        private function list_render(item:ItemTroop,index:int):void{
            var hmd:ModelHero = this.list.array[index];
            item.setData((this.list.selectedIndex == index),hmd);
            //
            var hadIndex:int = this.getIndex(hmd);
            item.offAll(Event.CLICK);
            item.on(Event.CLICK,this,this.click_troop2,[hmd,index,hadIndex]);
            item.setIndex((hadIndex>-1)?Tools.getMsgById("_climb44",[hadIndex+1]):Tools.getMsgById("_public88"));//"第"+(hadIndex+1)+"阵"
        }
        private function getIndex(hmd:ModelHero):int{
            var hadIndex:int = -1;
            for(var i:int = 0; i < this.mArr.length; i++)
            {
                if(this.mArr[i]){
                    if(this.mArr[i].id == hmd.id){
                        hadIndex = i;
                        break;
                    }
                }
            }
            return hadIndex;
        }
        private function click():void{
            if(this.list.selectedIndex>-1){
                var hmd:ModelHero = this.list.array[this.list.selectedIndex];
                //
                var hadIndex:int = this.getIndex(hmd);
                if(hadIndex>-1){
                   this.mArr[hadIndex] = this.mSelected;
                }
                this.mArr[this.mIndexCurr] = hmd;
                //
                if(this.mUpdate){
                    this.mUpdate.run();
                    this.mUpdate = null;
                }
                //
                this.closeSelf();
            }
        }
        private function click_troop2(hmd:ModelHero,index:int,hadIndex:int):void{
            if(index!=this.list.selectedIndex){
                if(this.list.selection){
                    (this.list.selection as ItemTroop).select.visible = false;
                }
                this.list.selectedIndex = index;
            }
        }
        private function list_select(index:int):void{
            if(index>-1){
                if(this.list.selection){
                    (this.list.selection as ItemTroop).select.visible = true;
                }
            }
        }
    }   
}