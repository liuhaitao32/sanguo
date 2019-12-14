package sg.view.fight
{
    import ui.fight.itemPKopponentUI;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import sg.model.ModelClimb;
    import sg.model.ModelUser;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;

    public class ItemPKopponent extends itemPKopponentUI{
        private var mData:Object;
        private var mTempMyData:Object;
        private var mStatus:int = -1;
        public function ItemPKopponent(){
            this.text0.text=Tools.getMsgById("_public214");

        }
        public function setData(data:Object,tempMyData:Object):void{
            this.mData = data;
            this.mTempMyData = tempMyData;
            this.btn.off(Event.CLICK,this,this.click_pk);
            this.btn.on(Event.CLICK,this,this.click_pk);
            var isMe:Boolean = (this.mData.uid == ModelManager.instance.modelUser.mUID);
            this.tName.text = data.uname;
			this.comPower.setNum(isMe?ModelManager.instance.modelUser.getPower(false, ModelClimb.getPKdeployMax()):data.power);
            //this.tPower.text = ""+(isMe?ModelManager.instance.modelUser.getPower(false,ModelClimb.getPKdeployMax()):data.power);
            this.tIndex.text = data.rank+"";
            this.mCountry.setCountryFlag(this.mData.uid<0?3:(data.hasOwnProperty("country")?data.country:ModelUser.getCountryID()));
            
            this.btn.visible = !isMe;
            this.btnClear.visible = false;
            if(data.rank>this.mTempMyData.rank){
                this.btn.label = Tools.getMsgById("_pve_text04");
                this.btnClear.visible = true;
                this.mStatus = 1;
            }
            else{
                this.btn.label = Tools.getMsgById("_climb15");//"挑战";//挑战
                this.mStatus = 0;
                if(this.mTempMyData.rank<21){
                    if((this.mTempMyData.rank - data.rank)>4){
                        this.mStatus = -1;
                    }
                }
                else{
                    if(data.rank<11){
                        this.mStatus = -1;
                    }
                }
            }
            this.btn.visible = (this.mStatus>=0 && !isMe);
            //
            var uidNum:Number = Number(this.mData.uid);
            var hid:String = "";
            var hero_star:int = 0;
            //
            if(!isMe){
                if(this.mData.head){
                    hid = this.mData.head;

                }
                else{
                    var troop0:Object = this.mData.troop[0];
                    hid = troop0["hid"];                    
                }
                // hero_star = troop0.hasOwnProperty("hero_star")?troop0["hero_star"]:0;
            }
            else{
                hid = ModelManager.instance.modelUser.getHead();
                // hero_star = ModelManager.instance.modelGame.getModelHero(hid).getStar();
            }
            //
            this.heroIcon.setHeroIcon(hid);//,true,ModelHero.getHeroStarGradeColor(hero_star)
        }
        private function click_pk():void{
            if(this.mStatus > -1){
                var max:Number = ConfigServer.pk.pk_robot[ConfigServer.pk.pk_robot.length-1][0];
                ViewManager.instance.showView(ConfigClass.VIEW_PK_DEPLOY,[this.mData,this.mTempMyData.rank>=max?null:this.mTempMyData,this.mStatus]);
            }
            else{
                //能力不行,不能挑战高级别的
            }
        }
    }   
}