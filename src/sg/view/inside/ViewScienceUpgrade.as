package sg.view.inside
{
    import ui.inside.science_upgradeUI;
    import sg.model.ModelScience;
    import laya.events.Event;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import laya.ui.Box;
    import ui.com.payTypeBigUI;
    import sg.model.ModelItem;
    import sg.cfg.ConfigColor;
    import sg.model.ModelBuiding;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import ui.com.payTypeSUI;
    import sg.model.ModelInside;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.manager.EffectManager;
    import laya.display.Animation;

    public class ViewScienceUpgrade extends science_upgradeUI
    {
        private var mModel:ModelScience;
        private var mBoxPay:Box;
        private var mModelUpgrade:ModelScience;
        private var canUp:Boolean = false;
        private var mCostArr:Array=[];
        public function ViewScienceUpgrade()
        {
            this.comTitle.setViewTitle(Tools.getMsgById("_science10"));
            this.btn_coin.on(Event.CLICK,this,this.click,[1]);
            this.btn_cd.on(Event.CLICK,this,this.click,[0]);
            this.btn_quick.on(Event.CLICK,this,this.click_quick);
            //
            this.mBoxPay = new Box;
            this.mBox.addChild(this.mBoxPay);
			this.mingcheng.text = Tools.getMsgById("ViewScienceUpgrade_1");
			this.dengji.text = Tools.getMsgById("_hero14");
			this.tStatus2.text = Tools.getMsgById("ViewScienceUpgrade_2");
			this.priceRuler.text = Tools.getMsgById("treasure_text03");
			this.tTips.text = Tools.getMsgById("_public12");
            this.btn_quick.label = Tools.getMsgById('_building21');
        }
        override public function onAdded():void{
            ModelManager.instance.modelGame.on(ModelInside.SCIENCE_CHANGE_STATUS,this,this.update_smd);
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelInside.SCIENCE_CHANGE_STATUS,this,this.update_smd);
        }
        private function update_smd():void{
            this.initData();
        }    
		private function getValueStr(value:Number, type:int):String{
			if (type == 0){
				return value.toString();
            }
			else{
				return Tools.percentFormat(value);
            }
        }        
        override public function initData():void{
            this.mModel = this.currArg;
            //
            this.mModelUpgrade = ModelScience.getCDingModel();
            //
            this.btn_coin.setData("",this.mModel.getLvCDcoin(this.mModel.getLv()));
            this.btn_cd.setData(AssetsManager.getAssetsUI("img_icon_02.png"),Tools.getTimeStyle(this.mModel.getLvCD(this.mModel.getLv())*Tools.oneMillis));
            //
            this.tName.text = this.mModel.getName(true);
            //
            this.icon.setScienceUI(this.mModel,true);
            //
            var attArr:Array = this.mModel.getAtt();
			var lv:int = this.mModel.getLv();
			var currValueStr:String = this.getValueStr(attArr[1] * lv, attArr[2]);
			if (lv >= this.mModel.max_level){
				//最大等级限制
				this.tLv.text = lv + " ("+Tools.getMsgById("_public9")+")";//满级
				this.tInfo.text = attArr[0] + ": " + currValueStr;
			}
			else{
				var nextValueStr:String = this.getValueStr(attArr[1] * (lv+1), attArr[2]);
				this.tLv.text = lv + "  >>  " + (lv + 1);
				this.tInfo.text = attArr[0] + ": " + currValueStr + "  >>  " + nextValueStr;
			}
            //
            this.mQuick.visible = !Tools.isNullObj(this.mModelUpgrade);
            if(this.mQuick.visible){
                if(this.mModelUpgrade.getLastCDtimer()<=1000){
                    this.mQuick.visible = false;
                }
                else{
                    this.tQuick.text = Tools.getMsgById("_science1",[this.mModelUpgrade.getName()]);//"正在研发"+this.mModelUpgrade.getName();//正在研发
                }
                this.iconUp.setScienceUI(this.mModelUpgrade,true);
            }
            //
            var lock2:Array = this.mModel.checkLock2();
            this.canUp = lock2[0];
            this.tStatus.visible = !lock2[0];
            this.tStatus2.visible = this.tStatus.visible;
            //
            if (!lock2[0] && lock2[1].length > 0){
				var lockMsgId:String = lock2[1].length > 1 ? '_science9':'_science2';
                this.tStatus.text = Tools.getMsgById(lockMsgId,[ModelManager.instance.modelGame.getModelScience(lock2[1][0][0]).getName(),lock2[1][0][1]]);
                this.tStatus.color = lock2[0]?ConfigColor.TXT_STATUS_OK_GREEN:ConfigColor.TXT_STATUS_NO;
                // ModelManager.instance.modelGame.getModelScience(lock2[1][0][0]).getName()+"达到"+lock2[1][0][1]+"级";//达到{}级
            }
            this.tTips.visible = (lv >= this.mModel.max_level);
            this.btn_coin.visible = !this.tTips.visible;
            this.btn_cd.visible = !this.tTips.visible;
            //
            this.btn_coin.gray = !this.canUp;
            this.btn_cd.gray = !this.canUp;
            //
            if(!Tools.isNullObj(this.mModelUpgrade)){
                this.btn_coin.gray = true;
                this.btn_cd.gray  = true;
            }
            //
            this.showPayUI();
        }
        private function showPayUI():void{
            if(this.mBoxPay){
                this.mBoxPay.destroyChildren();
            }
            mCostArr=[];
            //
            var arr:Array = this.mModel.getLvUpItems(this.mModel.getLv());
            var len:int = arr.length;
            var item:payTypeSUI;
            var key:String;
            var val:Number;
            var enough:Boolean = false;
            for(var i:int = 0; i < len; i++)
            {
                key = arr[i][0];
                val = Math.floor(arr[i][1]*(1-ModelScience.func_sum_type(ModelScience.ology_consume,key)));
                item = new payTypeSUI();
                if(key.indexOf("item")>-1){
                    enough = ModelItem.getMyItemNum(key)>=val;
                    item.setData(AssetsManager.getAssetsICON(ModelItem.getItemIcon(key)),val);
                    item.changeTxtColor(enough?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO);
                }
                else{
                    enough = ModelBuiding.getMaterialEnough(key,val);
                    item.setData(ModelBuiding.getMaterialTypeUI(key),val);
                    item.changeTxtColor(enough?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO);
                }
                mCostArr.push([key,val]);
                item.on(Event.CLICK,this,costClick,[i]);
                this.mBoxPay.addChild(item);
                item.x = i*(120);
            }
            this.mBoxPay.x = this.priceRuler.x+(this.mBox.width - this.mBoxPay.width)*0.5;
            this.mBoxPay.y = this.priceRuler.y - 10;
        }

        private function costClick(index:int):void{
            ViewManager.instance.showItemTips(mCostArr[index][0]);
        }

        private function click_quick():void
        {
            this.closeSelf();
            ViewManager.instance.showView(ConfigClass.VIEW_SCIENCE_QUICKLY,this.mModelUpgrade);
        }
        private function click(type:int):void
        {
            if(!Tools.isNullObj(this.mModelUpgrade)){
                if(this.mModelUpgrade.getLastCDtimer()<=1000){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht62"));
                }
                else{
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht61"));
                }
                
                return;
            }
            if(!this.canUp){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht53",[this.tStatus.text]));
                return
            }
            for(var i:int=0;i<mCostArr.length;i++){
                if(!Tools.isCanBuy(mCostArr[i][0],mCostArr[i][1])){
                    return;
                }
            }
            if(type==1){
                if(!Tools.isCanBuy("coin",this.mModel.getLvCDcoin(this.mModel.getLv()))){
                    return;
                }
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_SCIENCE_LVUP,{sid:this.mModel.id,cost:type},Handler.create(this,this.ws_sr_science_lvup),type);
        }
        private function ws_sr_science_lvup(re:NetPackage):void
        {
            ModelManager.instance.modelUser.updateData(re.receiveData);
            ModelManager.instance.modelInside.upgradeScienceCDByArr();
            //
            if(re.sendData.cost == 1){
                ModelManager.instance.modelInside.checkScienceGet();
            }
            else{
                ModelManager.instance.modelGame.event(ModelInside.SCIENCE_CHANGE_STATUS);
            }
            var ani:Animation = EffectManager.loadAnimation("glow007","",1);
            ani.scaleX = 2.4;
            ani.scaleY = 2.4;
			ani.pos(tInfo.x + tInfo.width * 0.5, tInfo.y + tInfo.height * 0.5);
			mBox.addChild(ani);
            // this.closeSelf();            
        }
    }
}