package sg.view.inside
{
    import sg.model.ModelEquip;
    import sg.model.ModelBuiding;
    import sg.manager.ModelManager;
    import sg.model.ModelInside;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigServer;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.utils.Tools;
    import sg.model.ModelItem;

    public class ViewEquipQuickly extends ViewBuildingQuickly{

        private var mEquipModel:ModelEquip;//
        private var needCoin:Number=0;
        public function ViewEquipQuickly():void{
            super();
            this.mTypeCD = 1;
        }
        override public function initData():void{
            this.mEquipModel = this.currArg as ModelEquip;
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
            this.mTimerAll = this.mEquipModel.getLvCD(this.mEquipModel.getLv()+1)*Tools.oneMillis;
            this.mTimerLast = this.mEquipModel.getLastCDtimer();
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
                //this.tname.text = this.mEquipModel.isSpecial()?this.mEquipModel.getName():this.mEquipModel.getTypeName();
                this.comTitle.setViewTitle(this.mEquipModel.isSpecial()?this.mEquipModel.getName():this.mEquipModel.getTypeName());
                this.ttime.text = this.mEquipModel.getLastCDtimerStyle();
                //
                this.tStatus.text = Tools.getMsgById("_equip10");
                //
                this.mProgress.initData(580,this.mTimerAll,passTimer);
                this.btn_free.visible = false;
                this.btn_cd.visible = true;
                this.btn_coin.visible = true;
                //
                this.bar_time.value = passTimer/this.mTimerAll;
                //
                this.btn_coin.setData("",ModelBuiding.getCostByCD(m,this.mTypeCD));
                needCoin=ModelBuiding.getCostByCD(m,this.mTypeCD);
                //
            }            
        }
        override public function click(type:int):void{
            var s:Object;
            var num:int = parseInt(this.tCdNum.text);
            if(type==1){
                s = {item_id:-1,item_num:1,equip_id:this.mEquipModel.id};
                if(!Tools.isCanBuy("coin",needCoin)){
                    return;
                }
            }
            else{
                if(this.autoID == ""){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building2"));//没有cd道具
                    return ;
                }
                else{
                    s = {item_id:this.autoID,item_num:num,equip_id:this.mEquipModel.id};
                }
                var status:Array = ModelItem.checkCDitemStatus(s.item_id,num,this.mTimerLast,this.mTypeCD);
                if(status[0]<0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_public36"));//没有那么多
                    return;
                }
                if(status[1]>0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building3",[status[1]]));
                    return;
                }
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_KILL_EQUIP_CD,s,Handler.create(this,this.ws_sr_kill_equip_cd),s);
        }
        private function update_cd(md:ModelBuiding):void{
            if(md.id == this.mEquipModel.id){
                this.checkUI();
            }
        }
        private function ws_sr_kill_equip_cd(re:NetPackage):void{
            var type:int = re.sendData.item_id;
            //
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            ModelManager.instance.modelInside.getBuilding002().updateStatus(true);
            if(type<0){
                this.closeSelf();
                return;
            }
            //
            this.checkUI();
            //
            this.checkBoxProps();
        }
    }
}