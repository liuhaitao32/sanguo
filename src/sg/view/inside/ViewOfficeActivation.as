package sg.view.inside
{
    import ui.inside.officeActivationUI;
    import laya.events.Event;
    import sg.model.ModelOfficeRight;
    import laya.ui.Box;
    import ui.com.payTypeUI;
    import sg.model.ModelBuiding;
    import sg.manager.AssetsManager;
    import sg.net.NetSocket;
    import laya.utils.Handler;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.model.ModelGame;
    import ui.com.payTypeBigUI;
    import sg.model.ModelOffice;
    import sg.model.ModelItem;
    import sg.cfg.ConfigServer;
    import sg.utils.MusicManager;

    public class ViewOfficeActivation extends officeActivationUI{
        private var mModel:ModelOfficeRight;
        private var mBox_pay:Box;
        public function ViewOfficeActivation(){
            this.comTitle.setViewTitle(Tools.getMsgById("_office9"));
            this.mBox_pay = new Box();
            this.mBox.addChild(this.mBox_pay);
            this.btn.on(Event.CLICK, this, this.click);
			this.btn.label = Tools.getMsgById("_jia0101");
            this.tText.text = Tools.getMsgById("_office9");
        }
        override public function initData():void{
            this.mModel = this.currArg;
            this.mIcon.btn.label = this.mModel.getName();
            this.mIcon.mLock.visible = false;
            this.tName.text = Tools.getMsgById(this.mModel.info);//this.mModel.getName();
            this.tInfo.text = this.mModel.getInfo();
            //
            this.setPayUI();
        }
        private function setPayUI():void{
            this.mBox_pay.removeChildren();
            //
            var arr:Array = this.mModel.getMaterial();
            var len:int = arr.length;
            var pay:Object;
            var item:payTypeBigUI;
            var numLess:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                pay = arr[i];
                item = new payTypeBigUI();
                item.setData(ModelBuiding.getMaterialTypeUI(pay.id),pay.num,pay.ok?-1:1);
                if(!pay.ok && numLess.length==0){
                    numLess.push(pay.id);
                    numLess.push(pay.num);
                }
                item.x = i*(item.width+30);
                this.mBox_pay.addChild(item);
            }
            this.mBox_pay.centerX = 0;
            this.mBox_pay.y = this.tInfo.y+this.tInfo.height+10;
            //
            var front:String = this.mModel.getFront();
            var vb:Boolean = false;
            var officeLv:int = this.mModel.getOfficeLv();
            //
            this.mIcon.btn.selected = this.mModel.isMine();
            if(this.mModel.isMine()){
                vb = true;
                this.tStatus.text = Tools.getMsgById("isCanBuy");//"已激活";//已激活
            }
            else{
                if(numLess.length>0){
                    vb = true;
                    this.tStatus.text = ModelManager.instance.modelProp.getItemProp(numLess[0]).name+Tools.getMsgById("_public95");
                }
                else if(ModelManager.instance.modelUser.office<officeLv){
                        vb = true;
                        this.tStatus.text = Tools.getMsgById("_office4",[ModelOffice.getOfficeName(officeLv)]);//"请先提升爵位到"+ModelOffice.getOfficeName(officeLv);//请先提升爵位到
                }
                else{
                    if(!Tools.isNullString(front) && !ModelOfficeRight.isOpen(front)){
                        var preMd:ModelOfficeRight = new ModelOfficeRight(front);
                        vb = true;
                        this.tStatus.text = Tools.getMsgById("_office5",[preMd.getName()]);//"需要先开启"+preMd.getName();//需要先开启
                        //
                        preMd = null;
                    }
                }
            }
            this.btn.visible = !vb;
            this.tStatus.visible = vb;

        }
        private function click():void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_OFFICE_RIGHT_UNBLOCK,{right_id:this.mModel.id},Handler.create(this,this.ws_sr_office_right_unblock));
        }
        private function ws_sr_office_right_unblock(re:NetPackage):void{
            MusicManager.playSoundUI(MusicManager.SOUND_UNLOCK_RIGHT);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            if(ConfigServer.office.righttype.baggagefree.indexOf(re.sendData.right_id)!=-1){
                ModelManager.instance.modelInside.getBuildingModel("building004").updateStatus();//辎重站免费次数更新
            }
            //
            this.closeSelf();
            //
            ModelManager.instance.modelGame.event(ModelGame.EVENT_OFFICE_RIGHT_CHANGE,re.sendData.right_id);
            //
            
        }
    }
}