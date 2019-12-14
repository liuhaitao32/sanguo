package sg.view.fight
{
    import ui.fight.climbTroopUI;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import sg.net.NetPackage;
    import laya.ui.Box;
    import sg.model.ModelHero;
    import ui.fight.pkTroopUI;
    import laya.maths.MathUtil;
    import sg.manager.ViewManager;
    import sg.model.ModelClimb;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;

    public class ViewPKtroop extends pkTroopUI{
        private var mSelectArr:Array;
        private var mBox_me:Box;
        //private var mItem:ItemPKhero;
        private var mItem:*;
        private var mTroopNum:int;
        private var mType:Number;//UI样式不一样  0 过关斩将   1 沙盘   2-10 擂台赛
        public function ViewPKtroop(){
            this.text0.text=Tools.getMsgById("_pk07");
            this.list.itemRender = ItemTroop;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            this.list.scrollBar.hide = true;
            //
            this.btn.on(Event.CLICK,this,this.click);
            this.btnHelp.on(Event.CLICK,this,this.click_help);
        }   
        override public function initData():void{
            this.mBox_me = this.currArg[0];
            this.mItem = this.currArg[1];
            this.mTroopNum = this.currArg[2];
            this.mType = this.currArg[3]?this.currArg[3]:0;
            //trace(this.currArg);
            //
            this.mSelectArr = [];
            //
            var myHeroArr:Array = mType>=2 ? ModelHero.getArenaHeroList(mType-2) : ModelManager.instance.modelUser.getMyHeroArr(true,"",null,true);
            var len:int = myHeroArr.length;
            var arr:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                if(!this.checkSelect(myHeroArr[i].id)){
                    arr.push(myHeroArr[i]);
                }
            }
            this.btn.disabled = true;
            this.btn.label = Tools.getMsgById("_public51");//"上阵";
            this.tNum.text = mType>=2 ? this.mTroopNum+"/"+this.mTroopNum : this.mTroopNum+"/"+5;
            //this.tTitle.text = Tools.getMsgById("_climb14");//"更选英雄";
            this.comTitle.setViewTitle(Tools.getMsgById("_climb14"));
            this.groupNum.text = Tools.getMsgById("_climb44",[this.mItem.mIndex+1]);//"第"+(this.mItem.mIndex+1)+"阵";
            //
            this.list.dataSource = arr;

            this.boxBtm.visible=mType!=0;
            this.list.height=(mType!=0)?500:566;
            this.imgBtm.bottom=(mType!=0)?36:-30;

        }   
        override public function onRemoved():void{
            this.list.selectedIndex = -1;
            this.mBox_me = null;
            this.mItem = null;
        }
        private function checkSelect(hid:String):Boolean{
            var len:int = this.mBox_me.numChildren;
            var item:ItemPKhero;
            for(var i:int = 0; i < len; i++)
            {
                item = this.mBox_me.getChildAt(i) as ItemPKhero;
                if(item.mIsFriend){
                    return false;
                }
                if(item.mStatus == 1 && item.mModel.id == hid){
                    return true;
                }
            }
            return false;
        }            
        private function list_render(item:ItemTroop,index:int):void{
            var hmd:ModelHero = this.list.array[index];
            // var isSelected:Boolean = this.checkSelect(hmd.id);
            item.setData(this.list.selectedIndex == index,hmd);
            item.setIndex(Tools.getMsgById("_public88"));//空闲
            item.offAll(Event.CLICK);
            item.on(Event.CLICK,this,this.click_troop3,[index]);
            item.boxState.visible=this.mType==0;
        }   
        private function click_troop3(index:int):void{
            if(index != this.list.selectedIndex){
                if(this.list.selection){
                    (this.list.selection as ItemTroop).setData(false,null);
                }
                this.list.selectedIndex = index;   
            }
        }
        private function list_select(index:int):void
        {
            this.btn.disabled = index<0;
            if(index>-1){
                if(this.list.selection){
                    (this.list.selection as ItemTroop).setData(true,null);
                    
                }
            }   
        }
        private function click_help():void
        {
            if(mType >= 2){
                str = Tools.getMsgById("_climb53",[this.mTroopNum]);//"最高上阵"+max+"个英雄";
            }else{
                var max:int = ModelClimb.getPKdeployMax();
                var str:String = "";
                if(max<ConfigServer.pk.pk_hero.length){
                    str = Tools.getMsgById("_climb52",[ConfigServer.pk.pk_hero[max],max+1]);
                    // "提升官邸到"+ConfigServer.pk.pk_hero[max]+"级,可以上阵"+(max+1)+"个英雄"
                }
                else{
                    str = Tools.getMsgById("_climb53",[max]);//"最高上阵"+max+"个英雄";
                }
            }
            
            ViewManager.instance.showTipsPanel(str);
        }
        private function click():void{
            if(this.list.selection){
                this.mItem.setDataMe(this.mItem.mIndex,(this.list.selection as ItemTroop).mModel);
            }
            this.closeSelf();
        }                
    }   
}