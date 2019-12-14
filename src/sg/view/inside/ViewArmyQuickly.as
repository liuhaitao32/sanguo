package sg.view.inside
{
    import sg.model.ModelBuiding;
    import sg.manager.ModelManager;
    import sg.model.ModelInside;
    import sg.utils.Tools;
    import sg.net.NetMethodCfg;
    import sg.net.NetSocket;
    import laya.utils.Handler;
    import sg.manager.ViewManager;
    import sg.model.ModelItem;
    import sg.net.NetPackage;

    public class ViewArmyQuickly extends ViewEquipQuickly{
        private var mModel:ModelBuiding;//
        public function ViewArmyQuickly():void{
            super();
            this.mTypeCD = 3;
        }
        override public function initData():void{
            this.mModel = this.currArg as ModelBuiding;
            //
        }
        override public function onAdded():void{
            ModelManager.instance.modelInside.on(ModelInside.ARMY_BUILDING_TRAIN_UPDATE_CD,this,this.army_building_train_update_cd);
            //
            this.checkUI();
            this.checkBoxProps();
        }
        override public function onRemoved():void{
            ModelManager.instance.modelInside.off(ModelInside.ARMY_BUILDING_TRAIN_UPDATE_CD,this,this.army_building_train_update_cd);
        }  
        override public function checkUI():void{
            this.mTimerAll = this.mModel.getArmyMakeCDms(this.mModel.getArmyMakingNum());
            this.mTimerLast = this.mModel.getMakingArmyLastTimer();
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
                //this.tname.text = this.mModel.getName();
                this.comTitle.setViewTitle(this.mModel.getName());
                this.ttime.text = Tools.getTimeStyle(this.mTimerLast);
                //
                this.tStatus.text = Tools.getMsgById("_building1");//训练加速
                //
                this.mProgress.initData(580,this.mTimerAll,passTimer);
                this.btn_free.visible = false;
                this.btn_cd.visible = true;
                this.btn_coin.visible = true;
                //
                this.bar_time.value = passTimer/this.mTimerAll;
                //
                this.needCoin=ModelBuiding.getCostByCD(m,this.mTypeCD);
                this.btn_coin.setData("",this.needCoin);
                //
            }            
        }
        private function army_building_train_update_cd(md:ModelBuiding):void{
            if(md.id == this.mModel.id){
                this.checkUI();
            }
        }
        override public function click(type:int):void{
            var s:Object;
            var num:int = parseInt(this.tCdNum.text);
            if(type==1){
                if(!Tools.isCanBuy("coin",this.needCoin)){
                    return;
                }                
                s = {item_id:-1,item_num:1,bid:this.mModel.id};
            }
            else{
                if(this.autoID == ""){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building2"));//没有cd道具
                    return ;
                }
                else{
                    s = {item_id:this.autoID,item_num:num,bid:this.mModel.id};
                }
                var status:Array = ModelItem.checkCDitemStatus(s.item_id,num,this.mTimerLast,this.mTypeCD);
                if(status[0]<0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_public19"));//材料不足
                    return;
                }
                if(status[1]>0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building3",[status[1]]));
                    return;
                }
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_KILL_ARMY_CD,s,Handler.create(this,this.ws_sr_kill_army_cd),s);
        }
        private function ws_sr_kill_army_cd(re:NetPackage):void{
            var type:int = re.sendData.item_id;
            ModelManager.instance.modelUser.updateData(re.receiveData);
            this.mModel.updateStatus();
            //
            if(type<0){
                this.closeSelf();
                return;
            }
            //
            this.checkUI();
            //
            this.checkBoxProps(); 
            
            ModelManager.instance.modelInside.event(ModelInside.ARMY_BUILDING_TRAIN_SPEED_UP);
        }
    }
}