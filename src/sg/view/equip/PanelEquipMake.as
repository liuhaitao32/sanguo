package sg.view.equip
{
	import ui.equip.panelEquipMakeUI;
	import sg.model.ModelEquip;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import laya.events.Event;
	import sg.view.com.EquipInfoAttr;
	import ui.com.payTypeUI;
	import sg.utils.Tools;
	import sg.manager.AssetsManager;
	import sg.model.ModelItem;
	import sg.cfg.ConfigColor;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.utils.MusicManager;
	import sg.model.ModelGame;
	import sg.model.ModelScience;
	import sg.utils.StringUtil;
	import sg.model.ModelBuiding;
	import sg.manager.EffectManager;

	/**
	 * ...
	 * @author
	 */
	public class PanelEquipMake extends panelEquipMakeUI{

		private var mEmd:ModelEquip;
		private var mEtype:int;
		private var mType:int;//0 制造  1 突破
		private var mInfoAttr:EquipInfoAttr;
		private var mOkNum:Number;
		private var mNumLen:Number;
		private var mNeedCoin:Number;
		private var mCfg:Array;
		public function PanelEquipMake(){
			this.btn0.on(Event.CLICK,this,click,[this.btn0]);
			this.btn1.on(Event.CLICK,this,click,[this.btn1]);
			this.btn_make.on(Event.CLICK,this,click,[this.btn_make]);

			this.tText.text=Tools.getMsgById("_equip41");
		}

		private function updateUI(eId:String,eType:int,type:int):void{
			
			mOkNum = mNumLen = 0;
			mEmd   = eId=="" ? null : ModelManager.instance.modelGame.getModelEquip(eId);
			mType  = type;
			mEtype = eType;
			var obj:Object = mType == 1 ? mEmd.getUpgradeCfgByLv(mEmd.getLv()+1) : null;
			var blv:int = ModelEquip.checkBuildLvCanUp(eType);
			var cfg:Object = ConfigServer.system_simple.equip_make_list[ModelEquip.equipDataArr[eType].type];

			this.equipArr.height = mType == 1 ? 176 : 222;
			//宝物突破
			this.box0.visible 	 = mType == 1;
			//宝物制造
			this.box1.visible 	 = mType == 0 && eType != 5;
			//全部制作完成||未到可制作等级
			this.box2.visible 	 = mType == 0  && (makeListAllFinish(eType) || ModelManager.instance.modelInside.getBuilding002().lv<blv);
			//资源消耗
			this.box3.visible    = this.box2.visible==false;

			this.btn_make.visible = !this.box2.visible;
			if(mEmd && mEmd.isMine()) this.btn_make.visible = false;
			
			this.btn0.visible    = this.btn1.visible = mType == 1;
			
			if(this.mInfoAttr){
                this.mInfoAttr.removeSelf();
                this.mInfoAttr.destroy(true);
            }

			this.boxNum.destroyChildren();
			var payObj:Object;
            var ui:payTypeUI;
			
			if(mType==0){
				if(eType==5){//特殊
					setEquipInfoArr();
					if(mEmd.make_item){
						payObj = mEmd.make_item;
					}
				}else{
					payObj = cfg[2];
				}
			}else if(mType==1){
				setEquipInfoArr();
				if(obj){
					 payObj = obj.cost; 
				}else{
					//无法再突破
					this.text0.text = Tools.getMsgById("_public192");
					this.box3.visible = this.btn0.visible = this.btn1.visible =false;
					return;
				}
			}

			var payArr:Array = Tools.getPayItemArr(payObj);
			mNumLen = payArr.length;
			var _posX:Number = 0;
			for(var i:int=0;i<payArr.length;i++){
				var b:Boolean = ModelItem.getMyItemNum(payArr[i].id)>=payArr[i].data;
				if(b) mOkNum++;
				ui = new payTypeUI();
				ui.setData(AssetsManager.getAssetItemOrPayByID(payArr[i].id),payArr[i].id.indexOf("item")>-1 ? ModelItem.getMyItemNum(payArr[i].id)+"/"+payArr[i].data : payArr[i].data);
                ui.changeTxtColor(b?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO);
				
				ui.width = ui.getTextFieldWidth() + 15;                
                ui.x = i==0 ? 0 : _posX;
				ui.centerY = 0;
                _posX = _posX + ui.width;

                ui.off(Event.CLICK,this,clickPay);
                ui.on(Event.CLICK,this,clickPay,[payArr[i].id]);
                this.boxNum.addChild(ui);
			}
			this.boxNum.width = _posX;
			this.boxNum.x = (this.width - this.boxNum.width)/2;
			this.tText.x = this.boxNum.x - this.tText.width;

			if(mType==0){
				this.btn_make.label = Tools.getMsgById("_equip40");
				this.text1.text = Tools.getMsgById("ViewEquipMake_1");
				this.btn_make.gray = mNumLen > mOkNum; 
				this.text2.style.fontSize = 18;
				this.text2.style.align = "center";
				this.text2.style.valign = "middle";
				if(makeListAllFinish(eType)){
					if(eType<5)
                    	this.text2.innerHTML = StringUtil.substituteWithColor(Tools.getMsgById("_equip8",[ModelEquip.equipDataArr[eType].text]),"#e2f2ff","#e2f2ff");
               	 	else
                    	this.text2.innerHTML = StringUtil.substituteWithColor(Tools.getMsgById("_equip38"),"#e2f2ff","#e2f2ff");
				}

				if(ModelManager.instance.modelInside.getBuilding002().lv<blv){
					this.text2.innerHTML = StringUtil.substituteWithColor(Tools.getMsgById("_equip9",[blv]),"#FF0000","#e2f2ff");
				}
				
			} 

			if(mType==1){
				this.btn0.gray = this.btn1.gray = mNumLen > mOkNum;
				var mm:Number = Math.ceil(obj.upgrade_time/(1+ModelScience.func_sum_type(ModelScience.equip_up_time)));
				var ms:Number = mm*Tools.oneMinuteMilli;
				mNeedCoin=ModelBuiding.getCostByCD(mm,1);

				//突破成功率{}失败后返回{}资源
				var okP:Number = (obj.chance+ModelScience.func_sum_type(ModelScience.equip_up_chance,mEmd.type+""));
				var s1:String = Tools.getMsgById("_equip24",[StringUtil.numberToPercent(okP)]);
				var s2:String = Tools.getMsgById("_equip12",[StringUtil.numberToPercent(okP),StringUtil.numberToPercent(ConfigServer.system_simple.equip_upgrade_fail)]);
				this.text0.text = (okP>=1) ? s1 : s2;
				
				this.btn0.setData("",ModelBuiding.getCostByCD(mm,1));
				this.btn0.textlabel.text = Tools.getMsgById("_lht3");//立即完成
				this.btn1.setData(AssetsManager.getAssetsUI("img_icon_02.png"),Tools.getTimeStyle(ms));

				EffectManager.changeSprColor(this.img00,3,false,ConfigColor.COLOR_WORSHIP);
				EffectManager.changeSprColor(this.img01,3,false,ConfigColor.COLOR_WORSHIP);
			}
		}

		private function clickPay(id:String):void{
            ViewManager.instance.showItemTips(id);
        }
		

		private function setEquipInfoArr():void{
			this.mInfoAttr = null;
            this.mInfoAttr = new EquipInfoAttr(this.equipArr,this.equipArr.width,this.equipArr.height);
            this.mInfoAttr.initData(mEmd);
            this.equipArr.addChild(this.mInfoAttr);

		}

		private function click(obj:*):void{
			if(mNumLen > mOkNum){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip39"));
				return;
			}
			switch(obj){
				case this.btn_make:
					var sd:Object;
					if(mEtype==5){
						sd = {equip_type:-1,equip_id:mEmd.id};
					}else{
						sd = {equip_type:ModelEquip.equipDataArr[mEtype].type};
					}
					NetSocket.instance.send(NetMethodCfg.WS_SR_EQUIP_MAKE,sd,Handler.create(this,this.makeCallBack));
					break;
				case this.btn1://一般突破
					NetSocket.instance.send(NetMethodCfg.WS_SR_EQUIP_UPGRADE,{equip_id:mEmd.id,if_cost:0},Handler.create(this,this.makeCallBack));
					break;
				case this.btn0://花钱突破
					if(!Tools.isCanBuy("coin",mNeedCoin)) return;
					NetSocket.instance.send(NetMethodCfg.WS_SR_EQUIP_UPGRADE,{equip_id:mEmd.id,if_cost:1},Handler.create(this,this.makeCallBack));
					break;
			}
		}



		private function makeCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
            //
            ModelManager.instance.modelInside.upgradeEquipCDByArr();
            //
            MusicManager.playSoundUI(MusicManager.SOUND_EQUIP_MAKE);
			//
			ModelManager.instance.modelGame.event(ModelGame.EVENT_CLOSE_EQUIP_MAIN);
		}


		/**
		 * 当前宝物列表是否都制作完成
		 */
		private function makeListAllFinish(eType:int):Boolean{
			var type:int = ModelEquip.equipDataArr[eType].type;
			var cfg:Object=type<5 ? ConfigServer.system_simple.equip_make_list[type] : ConfigServer.system_simple.equip_make_special;
			if(cfg){
				for(var i:int=0;i<cfg[1].length;i++){
					if(!ModelManager.instance.modelUser.equip.hasOwnProperty(cfg[1][i])){
						return false;
					}
				}
				return true;
			}
			return false;
		}

		public function removeCostumeEvent():void{
			
		}


		
	}

}