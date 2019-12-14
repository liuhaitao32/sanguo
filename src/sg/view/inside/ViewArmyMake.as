package sg.view.inside
{
    import ui.inside.armyMakeUI;
    import sg.model.ModelBuiding;
    import laya.utils.Handler;
    import laya.ui.Box;
    import sg.cfg.ConfigColor;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.model.ModelInside;
    import sg.model.ModelPrepare;
    import sg.manager.AssetsManager;
    import sg.manager.ViewManager;
    import sg.model.ModelHero;
    import sg.utils.MusicManager;
    import ui.com.payTypeUI;
    import ui.com.payTypeBigUI;

    /**
     * 造兵
     */
    public class ViewArmyMake extends armyMakeUI{
        private var mModel:ModelBuiding;
        private var mBox_pay:Box;
        private var mArmyGrade:Number = 0;
        private var mMaxNum:Number;
        private var mPayFalse:Array;
        private var need_coin:Number=0;
        public function ViewArmyMake():void{
            this.slider.changeHandler = new Handler(this,this.bar_change);
            this.mBox_pay = new Box();
            this.mBox.addChild(this.mBox_pay);
            //
            this.btn_cd.on(Event.CLICK,this,this.click,[0]);
            this.btn_coin.on(Event.CLICK,this,this.click,[1]);
            this.btn_max.on(Event.CLICK,this,this.click_max);
            this.btnAdd.on(Event.CLICK,this,this.click_slider,[1]);
            this.btnLess.on(Event.CLICK,this,this.click_slider,[-1]);

            this,btn_max.label = Tools.getMsgById('_bag_text10');
            this.comTitle.setViewTitle(Tools.getMsgById("502028"));//训练
            tPay.text = Tools.getMsgById("treasure_text03");
            txt_hint_choose.text = Tools.getMsgById("_jia0077") + Tools.getMsgById("502028") + Tools.getMsgById("_jia0106");
        }
        override public function initData():void{
            this.mModel = this.currArg as ModelBuiding;
            //
            this.mArmyGrade = this.mModel.getArmyCurrGrade();
            ///
            // this.tName.text = this.mArmyGrade + "级" +ModelHero.army_type_name[ModelBuiding.army_type[this.mModel.id]];//this.mModel.getName();
            //
            var max:Number = this.mModel.getArmyCanMakeNumMax();
            //
            var canNext:Array = this.mModel.getArmyMakePayCheck(100);
            //
            if(canNext[3]<0){
                max = 100;
            }
            var min:Number = 100;
            var curr:Number = this.mModel.getArmyNum();
            var storeMax:Number = this.mModel.getArmyNumMax();
            if(curr>=storeMax){
                max = 0;
                min = 0;
            }
            this.armyNum.text = Tools.getMsgById("_public22",[curr+"/"+storeMax]);//"库存: "+curr+"/"+storeMax;
            //
            this.slider.max = max;
            this.slider.min = min;
            this.slider.tick = 10;
            //
            this.mMaxNum = max;
            //
            this.slider.value = max;
            //
            this.setInfo();
            this.setArmyImg();
        }
        private function setArmyImg():void{
            this.img.skin = AssetsManager.getAssetsArmy("army"+this.mModel.getArmyType()+""+this.mModel.getArmyCurrGrade());
            //
        }
        private function bar_change(v:Number):void{
            if(v<0){
                return;
            }
            this.tNum.text = v+"";
            this.setPayUI(this.mModel.getArmyMakePayCheck(v>0?v:100),v);
        }
        private function click_max():void{
            this.slider.value = this.mMaxNum;
        }
        private function setPayUI(payArr:Array,num:Number):void{
            this.mBox_pay.destroyChildren();
            this.mPayFalse = [];
            //
            var len:int = payArr.length;
            var item:payTypeBigUI;
            var v:Number = 0;
            var icon:String = "";
            for(var i:int = 0; i < 3; i++)
            {
                v = payArr[i][1];
                if(v==0){
                    continue;
                }
                item = new payTypeBigUI();
                //item.scale(1.5, 1.5);
                icon = payArr[i][0];
                item.setData(AssetsManager.getAssetItemOrPayByID(icon),Math.abs(v));
                item.changeTxtColor(v<0?ConfigColor.TXT_STATUS_NO:ConfigColor.TXT_STATUS_OK);
                item.x = (150+10) * i;
                if(v<0){
                    this.mPayFalse.push(icon);
                }
                this.mBox_pay.addChild(item);
            }
            this.mBox_pay.x = (this.mBox.width - this.mBox_pay.width)*0.5;
            this.mBox_pay.y = this.tPay.y + this.tPay.height + 10;
            //
            this.btn_cd.visible = this.btn_coin.visible = (num>0);
            var tm:Number = this.mModel.getArmyMakeCD(num);
            this.btn_cd.setData(AssetsManager.getAssetsUI("img_icon_02.png"),Tools.getTimeStyle(tm*Tools.oneMillis));
            //var coin:Number = ModelBuiding.getCostByCD(tm/60,3);
            need_coin = ModelBuiding.getCostByCD(tm/60,3);
            this.btn_coin.setData("",need_coin);
        }
        override public function onAdded():void{

        }
        override public function onRemoved():void{
            this.slider.value = -1;
        }
        public function setInfo():void{  
            this.infoBox.setBuildingInfoInfo(this.mModel,false,false,-1,true);
        }
        private function click(type:int):void{
            if(this.mPayFalse.length>0){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public19"));
                return;
            }
            if(type==1){
                if(!Tools.isCanBuy("coin",need_coin)){
                    return;
                }
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_BUILDING_MAKE_ARMY,{bid:this.mModel.id,if_cost:type,army_mk_num:this.slider.value},Handler.create(this,this.ws_sr_building_make_army));
        }
        private function ws_sr_building_make_army(re:NetPackage):void{
            // Trace.log("ws_sr_building_make_army",re.receiveData);
            var if_cost:Number = Number(re.sendData.if_cost);

            ModelManager.instance.modelUser.updateData(re.receiveData);
            this.mModel.updateStatus(true);
            MusicManager.playSoundUI(MusicManager.SOUND_ARMY_MAKE);
            //
            if(if_cost==1){
                ModelManager.instance.modelInside.checkArmyGetNum(this.mModel);
            }
            this.closeSelf();
        }
        private function click_slider(type:int):void{
            if(type<0){
                if(this.slider.value>this.slider.min){
                    this.slider.value -=this.slider.tick;
                }
            }
            else if(type==0){
                // this.slider.max = this.autoNum;
                // this.slider.min = this.autoNum<=1?0:1;
                // this.slider.value = this.slider.max;
            }
            else{
                if(this.slider.value<this.slider.max){
                    this.slider.value +=this.slider.tick;
                }
            }
            // this.bar_change(0);
        }
    }   
}