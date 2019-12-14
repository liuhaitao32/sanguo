package sg.view.fight
{
    import ui.fight.itemRankUI;
    import sg.model.ModelUser;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import laya.maths.Rectangle;
    import sg.model.ModelItem;
    import ui.bag.bagItemUI;
    import laya.utils.Handler;
    import sg.utils.Tools;

    public class ItemRank extends itemRankUI{
        public function ItemRank(){
            this.bg.hitArea = new Rectangle(0,0,this.width - 100,this.height);
            this.list.renderHandler=new Handler(this,listRender);
        }
        public function setData(obj:Object,index:int):void{
            var myAward:Object = ModelManager.instance.modelClimb.getClimbRankAward(obj.rank);
            var arr:Array=ModelManager.instance.modelProp.getRewardProp(myAward.reward);
            this.list.array=arr;
            this.list.repeatX=arr.length;
            // trace(myAward);
            //this.itemIcon.setIcon(ModelItem.getItemIcon(myAward.show));
            //this.itemIcon.setData(myAward.show,-1,-1);            
            //this.itemIcon.mCanClick = false;
            //this.btn.offAll(Event.CLICK);
            //this.btn.on(Event.CLICK,this,this.click,[myAward.reward]);
            //this.btn.mouseThrough = false;
            // this.tIndex.text = obj.rank+"";
            // this.tCountry.text = ModelUser.country_name[obj.country];
            this.countryIcon.setCountryFlag(obj.country);
            this.tName.text = obj.uname +"";
            Tools.textFitFontSize(this.tName);
            
            this.tKill.text = obj.kill_num;
            //
            // this.img1.visible = (index==1);
            // this.img2.visible = (index==1);
            // this.img3.visible = (index==1);
            this.rankCom.setRankIndex(index+1,"",true);
        }

        private function listRender(cell:bagItemUI,index:int):void{
            var arr:Array=this.list.array[index];
            cell.setData(arr[0],arr[1],-1);
        }

        private function click(reward:Object):void{
            ViewManager.instance.showRewardPanel(reward,null,true);
        }
    }   
}