package sg.view.fight
{
    import ui.fight.climbRankUI;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.manager.ModelManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.model.ModelUser;
    import sg.model.ModelItem;
    import sg.utils.Tools;
    import ui.bag.bagItemUI;

    public class ViewClimbRank extends climbRankUI{

        private var mSelected:int = -1;
        private var mTestArr:Array;
        public function ViewClimbRank(){
            this.list.itemRender = ItemRank;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.visible = false;
            //
            // this.list.selectEnable = true;
            // this.list.selectHandler = new Handler(this,this.list_select);
            this.comTitle.setViewTitle(Tools.getMsgById("_climb56"));
            this.mItem.list.renderHandler=new Handler(this,this.listRender);
            this.text0.text=Tools.getMsgById("_public214");
            this.text1.text=Tools.getMsgById("_public206");
            
        }
        override public function initData():void{
            //
            this.mSelected = -1;
            //
            var rankArr:Array = this.currArg as Array;
            var len:int = rankArr.length;
            var myData:Object = null;
            for(var i:int = 0; i < len; i++)
            {
                if(rankArr[i].uid == ModelManager.instance.modelUser.mUID){
                    myData = rankArr[i];
                    myData["sortIndex"] = i;
                    break;
                }
            }
            //
            this.mTestArr = [];
            // for(i = 0;i<50;i++){
                this.mTestArr = this.mTestArr.concat(rankArr);
            // }
            //
            this.list.dataSource = this.mTestArr;
            //
            this.setUI(myData);

            this.text2.text=Tools.getMsgById("_climb59");
            this.img.width=this.text2.width+220;
        }
        private function setUI(data:Object):void{
            // this.mItem.tIndex.text = ""+(data?data.rank:"--");
            // this.mItem.tCountry.text = ModelUser.country_name[ModelUser.getCountryID()];
            this.mItem.countryIcon.setCountryFlag(ModelUser.getCountryID());
            this.mItem.tName.text = ModelManager.instance.modelUser.uname +"";
            Tools.textFitFontSize(this.mItem.tName);
            this.mItem.tKill.text = (data?data.kill_num:"--");  
            this.mItem.rankCom.setRankIndex(data?(data.sortIndex+1):0,"",true);
            if(data){
                var myAward:Object = ModelManager.instance.modelClimb.getClimbRankAward(data.sortIndex+1);
                //this.mItem.itemIcon.visible = true;
                //this.mItem.itemIcon.setIcon(ModelItem.getItemIcon(myAward.show));
                //this.mItem.itemIcon.setData(myAward.show);
                this.mItem.list.visible=true;
                this.mItem.list.array=ModelManager.instance.modelProp.getRewardProp(myAward.reward);
                this.mItem.list.repeatX=this.mItem.list.array.length;
            }
            else{
                this.mItem.list.visible=false;
                //this.mItem.itemIcon.visible = false;
            }
        }

        private function listRender(cell:bagItemUI,index:int):void{
            var arr:Array= this.mItem.list.array[index];
            cell.setData(arr[0],arr[1],-1);
        }

        private function list_render(item:ItemRank,index:int):void{
            item.setData(this.list.array[index],index);
            item.centerX = 0;
            item.bg.offAll(Event.CLICK);
            item.bg.on(Event.CLICK,this,this.click_user,[index]);
        }
        // private function list_select(index:int):void{
        //     this.mSelected = index;
        // }
        private function click_user(index:int):void{
            var obj:Object = this.list.array[index];
            ModelManager.instance.modelUser.selectUserInfo(obj.uid);
            //
            // this.list.selectedIndex = index;
        }
    }
}