package sg.view.inside
{
    import sg.model.ModelScience;
    import sg.manager.ModelManager;
    import sg.model.ModelInside;
    import sg.model.ModelBuiding;
    import sg.manager.ViewManager;
    import sg.model.ModelItem;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.utils.Tools;

    public class ViewScienceQuickly extends ViewEquipQuickly
    {
        private var mModelScience:ModelScience;//
        public function ViewScienceQuickly()
        {
            super();
            this.mTypeCD = 2;
        }
        override public function initData():void{
            this.mModelScience = this.currArg as ModelScience;
            //
        }  
        override public function onAdded():void{
            ModelManager.instance.modelInside.on(ModelInside.EQUIP_UPDATE_CD,this,this.update_cd);
            //
            this.checkUI();
            this.checkBoxProps();
        }
        override public function onRemoved():void{
            ModelManager.instance.modelInside.off(ModelInside.EQUIP_UPDATE_CD,this,this.update_cd);
        } 
        override public function checkUI():void{
            this.mTimerAll = this.mModelScience.getLvCD(this.mModelScience.getLv()+1)*Tools.oneMillis;
            this.mTimerLast = this.mModelScience.getLastCDtimer();
            //
            if(this.mTimerLast<=1000){
                this.closeSelf();
                return;
            }
            //
            var m:Number = (this.mTimerLast*0.001)/60;
            var passTimer:Number = this.mTimerAll - this.mTimerLast;
            //
            if(this.reUIbyCD!=m){
                this.reUIbyCD = m;
                //
                //this.tname.text = this.mModelScience.getName();
                this.comTitle.setViewTitle(this.mModelScience.getName());
                this.ttime.text = this.mModelScience.getLastCDtimerStyle();
                //
                this.tStatus.text = Tools.getMsgById("_public50");//"升级加速";//升级加速
                //
                this.mProgress.initData(580,this.mTimerAll,passTimer);
                this.btn_free.visible = false;
                this.btn_cd.visible = true;
                this.btn_coin.visible = true;
                //
                this.bar_time.value = passTimer/this.mTimerAll;
                //
                this.btn_coin.setData("",ModelBuiding.getCostByCD(m,this.mTypeCD));
                //
            }            
        } 
        override public function click(type:int):void{
            var s:Object;
            var num:int = parseInt(this.tCdNum.text);
            if(type==1){
                s = {item_id:-1,item_num:1};
            }
            else{
                if(this.autoID == ""){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building2"));//"没有cd道具"
                    return ;
                }
                else{
                    s = {item_id:this.autoID,item_num:num};
                }
                var status:Array = ModelItem.checkCDitemStatus(s.item_id,num,this.mTimerLast,this.mTypeCD);
                if(status[0]<0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_public36"));//没有那么多
                    return;
                }
                if(status[1]>0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building3"));//
                    return;
                }
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_KILL_SCIENCE_CD,s,Handler.create(this,this.ws_sr_kill_science_cd),s);
        }        
        private function update_cd(md:ModelBuiding):void{
            if(md.id == this.mModelScience.id){
                this.checkUI();
            }
        }  
        private function ws_sr_kill_science_cd(re:NetPackage):void{
            var type:int = re.sendData.item_id;
            //
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            var getit:Boolean = false;
            //
            if(type<0){
                getit = true;
            }
            else{   
                this.mTimerLast = this.mModelScience.getLastCDtimer();
                //
                if(this.mTimerLast<=1000){
                    getit = true;
                }        
            }
            if(getit){
                ModelManager.instance.modelInside.checkScienceGet();
                this.closeSelf();
                return;
            }
            ModelManager.instance.modelInside.getBuilding003().updateStatus(true);
            ModelManager.instance.modelGame.event(ModelInside.SCIENCE_CHANGE_STATUS);
            //
            this.checkUI();
            //
            this.checkBoxProps();
        }                    
    }
}