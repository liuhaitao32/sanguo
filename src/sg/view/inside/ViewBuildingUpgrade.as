package sg.view.inside
{
	import ui.inside.buildingUpdateUI;
	import sg.model.ModelBuiding;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.ui.Box;
	import ui.inside.itemUpdateBuilderUI;
	import ui.com.payTypeUI;
	import laya.utils.Handler;
	import laya.ui.Label;
	import ui.inside.itemPreUI;
	import sg.cfg.ConfigColor;
	import sg.model.ModelInside;
	import sg.net.NetSocket;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.model.ModelHero;
	import ui.com.payTypeBigUI;
	import sg.model.ModelOffice;
	import sg.model.ModelPrepare;
	import sg.manager.AssetsManager;
	import sg.scene.view.MapCamera;
	import sg.boundFor.GotoManager;
	import laya.ui.Image;
	import sg.model.ModelGame;

	/**
	 * ...
	 * @author
	 */
	public class ViewBuildingUpgrade extends buildingUpdateUI{
		private var mModel:ModelBuiding;//当前封地建筑
		private var mBuiderBox:Box;
		private var mPayBox:Box;
		//
		private var update_pay:Array = null;
		private var update_builder:Boolean = false;
		private var isFree:Boolean = false;
		private var buyCoin:Number;
		//
		public function ViewBuildingUpgrade(){
			this.mBuiderBox = new Box();
			this.mPayBox = new Box();
			this.mBox.addChild(this.mBuiderBox);
			this.mBox.addChild(this.mPayBox);
			//
			this.list_if.itemRender = itemPreUI;
			this.list_if.renderHandler = new Handler(this,this.list_render);
			this.list_if.scrollBar.hide = true;
			//
			this.btn_coin.on(Event.CLICK,this,this.click_update,[1]);
			this.btn_cd.on(Event.CLICK,this,this.click_update,[0]);
			this.btn_free.on(Event.CLICK,this,this.click_update,[-1]);
			//
			this.btnInfo.on(Event.CLICK,this,this.click_info);
			this.tPay.text = Tools.getMsgById('treasure_text03');
			bBox.txt_hint_lv.text = Tools.getMsgById('_hero14');
			txt_title1.text = Tools.getMsgById('_jia0105') + Tools.getMsgById('_jia0033');
			this.btn_free.label = Tools.getMsgById("_lht70");
		}
		private function click_info():void
		{
			this.bInfo.visible = !this.bInfo.visible;
			this.bBoxInfo.visible = !this.bInfo.visible;
		}
		override public function initData():void{

			this.btnInfo.visible = !ModelGame.unlock(null,"text_unlock").stop;
			//
			this.mModel = this.currArg as ModelBuiding;
			//
			var nextLvCD:Number = this.mModel.getLvCD(this.mModel.lvNext());
			var nextLvCDms:Number = nextLvCD*Tools.oneMillis;
			//
			this.isFree = nextLvCDms<=0;
			//
			this.btn_cd.setData(AssetsManager.getAssetsUI("img_icon_02.png"),Tools.getTimeStyle(nextLvCD*Tools.oneMillis));
			//
			var coin:Number = this.mModel.getLvCDminute(this.mModel.lvNext())-this.mModel.getCDfree();
			coin = coin<0?0:coin;
			
			buyCoin = ModelBuiding.getCostByCD(coin);
			this.btn_coin.setData("",(buyCoin>0)?buyCoin+"":Tools.getMsgById("_building22"),-1,(buyCoin>0)?0:1);//直接升级
			(this.btn_coin.getChildByName("bg") as Image).skin = AssetsManager.getAssetsUI(buyCoin > 0 ? 'btn_no.png' : 'btn_yes.png');
			this.btn_coin.gray = (ModelManager.instance.modelUser.coin<buyCoin);
			//
			//this.tTitle.text = this.mModel.getName()+Tools.getMsgById("_building23");//升级
			this.comTitle.setViewTitle(this.mModel.getName()+Tools.getMsgById("_building23"));
			//
			this.bBox.setBuildingInfoLv(this.mModel,false,false);
			this.bBoxInfo.setBuildingInfoInfo(this.mModel);
			//
			this.tBinfo.text = this.mModel.getInfo();
			this.bInfo.visible = false;
			this.bBoxInfo.visible = !this.bInfo.visible;
		}
		override public function onAdded():void{
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_UPDATE_END,this,this.building_update_end);
			this.list_if.visible = false;
			this.box_update.visible = false;
			this.btn_free.visible = false;
			this.tMax.visible = false;
			this.setBuider();
			this.setPay();
			this.setPerBuiding();
		}
		override public function onRemoved():void{
			ModelManager.instance.modelInside.off(ModelInside.BUILDING_UPDATE_END,this,this.building_update_end);
			Laya.timer.clear(this,this.updateSelf);
			this.mBuiderBox.destroyChildren();
			this.mPayBox.destroyChildren();
		}
		private function building_update_end(md:ModelBuiding):void{
			Laya.timer.once(1000,this,this.updateSelf);
		}
		private function updateSelf():void{
			this.onRemoved();
			this.initData();
			this.onAdded();
		}
		/**
		 * 建筑升级农民
		 */
		private function setBuider():void{
			this.update_builder = false;
			var arr:Array = ModelManager.instance.modelInside.mBuildingArr;
			var len:int = arr.length;
			var item:itemUpdateBuilderUI;
			var md:ModelBuiding;
			// Trace.log("lenlenlen",len);
			if(len>=ModelManager.instance.modelInside.buildingUpgradeMax()){
				this.tbuilder_ok.text = "";
				for(var i:int = 0; i < len; i++)
				{
					md = arr[i] as ModelBuiding;
					if(md.isUpgradeIng()){
						item = new itemUpdateBuilderUI();
						item.btn_quick.label = Tools.getMsgById('_building21');
						item.x = 0;
						item.y = (i-1)*(item.height+2);
						item.btn_quick.on(Event.CLICK,this,this.onClick_quick,[arr[i] as ModelBuiding]);
						item.label.text = md.getName();
						item.tStatus.text = Tools.getMsgById("_building24")+md.getLastCDtimerStyle();//建设中
						this.mBuiderBox.addChild(item);
					}
					else{
						break;
						this.update_builder = true;
					}
				}
			}
			else{
				this.update_builder = true;
			}
			if(this.update_builder){
				this.tbuilder_ok.text = Tools.getMsgById("_building25");//"有空闲的农民";
			}
			this.mBuiderBox.y = this.line.y;// - this.mBuiderBox.height*0.5;
			this.mBuiderBox.centerX = 0;
		}
		/**
		 * 消耗币
		 */
		private function setPay():void{
			this.update_pay = [];
			var material:Array = this.mModel.checkPay(null,this.mModel.lvNext());
			var len:int = material.length;
			var element:Array;
			var item:payTypeBigUI;
			//
			this.mPayBox.destroyChildren();
			//
			for(var index:int = 0; index < len; index++)
			{
				element = material[index];
				item = new payTypeBigUI();
				item.setData(ModelBuiding.getMaterialTypeUI(element[0],true),element[1]);
				item.x = (item.width+30)*index;
				item.mLabel.color = element[2]?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO;
				if(!element[2]){
					this.update_pay.push(element);
				}
				this.mPayBox.addChild(item);
			}			
			this.mPayBox.x = this.tPay.x + this.tPay.displayWidth + 30;
			this.mPayBox.y = this.tPay.y - 10;
		}
		/**
		 * 前置建筑
		 */
		private function setPerBuiding():void{
			var arr:Array = this.mModel.checkPrecondition(null,this.mModel.lvNext());
			var len:int = arr.length;
			var element:Object;
			var isAllok:Boolean = true;
			var newArr:Array = [];
			var proDic:Object = {};
			//
			if(len>0){
				var otherArr:Array;
				var setB:Boolean = true;
				for(var i:int = 0;i < len;i++){
					otherArr = arr[i];
					setB = true;
					if(otherArr[0].indexOf(ModelBuiding.NAME_HEAD)>-1){
						if(otherArr.length>3){
							if(otherArr[4] == "and"){
								if(otherArr[3]>-1 || otherArr[5]){
									if(ModelManager.instance.modelInside.getBuildingModel(otherArr[0]).lv<otherArr[1]){
										proDic[""+otherArr[3]] = [otherArr[0],otherArr[1],otherArr[2]];
										setB = false;
									}
								}
							}
						}
						if(ModelManager.instance.modelInside.getBuildingModel(otherArr[0]).lv>=otherArr[1]){
							setB = false;
						}
					}
					if(setB){
						newArr.push(arr[i]);
					}
				}
				if(proDic){
					for(var key:String in proDic){
						newArr.push(proDic[key]);
					}
					
				}
				// trace(newArr,proDic);
				this.list_if.visible = true;
				this.list_if.array = newArr;
			}
			else{
				this.box_update.visible = !this.isFree;
				this.btn_free.visible = this.isFree;
			}
			if(this.mModel.checkIsMaxLv(this.mModel.lv+1)){
				this.box_update.visible = false;
				this.btn_free.visible = false;
				this.tMax.visible = true;
				this.tMax.text = Tools.getMsgById("_public12");
			}
		}
		private function list_render(item:itemPreUI, index:int):void{

			var data:Array = this.list_if.array[index] as Array;
			var id:String = data[0];
			item.btn_go.label = Tools.getMsgById("_jia0032");
			item.btn_go.visible = false;
			item.btn_go.off(Event.CLICK,this,this.click_go);
			if(id.indexOf(ModelBuiding.NAME_HEAD)>-1){
				var md:ModelBuiding = ModelManager.instance.modelInside.getBuildingModel(id);
				// item.txt.text = md.getName();
				item.tInfo.text = Tools.getMsgById(data[2],[data[1],md.getName()]);
				item.btn_go.on(Event.CLICK,this,this.click_go,[id,-1]);
				item.btn_go.visible = true;
			}
			else{//爵位
				item.tInfo.text = Tools.getMsgById(60118,[Tools.getMsgById(ModelOffice.getCfgOfficeById(data[1]).name)]);
				item.btn_go.on(Event.CLICK,this,this.click_go,[id,data[1]]);
				item.btn_go.visible = true;
			}			
		}
		private function click_go(bid:String,oLv:Number = -1):void{
			this.closeSelf();
			if(oLv!=-1){
				ViewManager.instance.showView(ConfigClass.VIEW_OFFICE_MAIN,oLv);
				return
			}
			var bmd:ModelBuiding = ModelManager.instance.modelInside.getBuildingModel(bid);
			MapCamera.lookAtBuild(bid);
			var sid:int = ModelManager.instance.modelInside.checkBuildingStatus(bmd)%10;
			if(sid==0){
				GotoManager.boundForPanel(GotoManager.VIEW_BUILDING_UPGRADE,"",bmd);
			}
		}
		private function click_update(type:int):void{
			//
			var proType:int = type;
			if(this.btn_coin.gray && type == 1){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public35"));//元宝不足,无法升级
				return;
			}
			if(!this.update_builder && type==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building26"));//没有空闲的升级队列
				return;
			}
			if(this.list_if.visible){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building27"));//前置建筑等级条件不满足
				return;					
			}

			//if(this.update_pay.length>0){
			//	ViewManager.instance.showTipsTxt(Tools.getMsgById("_public36"));//没有足够的消耗物品
			//	return;
			//}
			  if(this.update_pay.length>0){
                for(var i:int=0;i<update_pay.length;i++){
                    if(!Tools.isCanBuy(update_pay[i][0],update_pay[i][1])){
                        return;
                    }    
                }
            }
			if(proType==-1){
				proType = 0;
			}
			//
			// if(proType == 1 && buyCoin > 0){
			// 	var s:String = Tools.getMsgById('other_1',[buyCoin]);
			// 	ViewManager.instance.showAlert(s,function(index:int):void{
			// 		if(index == 0){
			// 			building_lv_up(proType);
			// 		}
			// 	},null,'',false,false,'build_upgrade');
			// }else{
			 	building_lv_up(proType);
			// }
			
			
		}

		private function building_lv_up(proType:int):void{
			ModelManager.instance.modelInside.building_lv_up(this.mModel,proType,Handler.create(this,this.ws_sr_building_lv_up));
		}


		private function ws_sr_building_lv_up():void{
			//
			ModelManager.instance.modelGame.checkPKnpcCaptain(true);
			//
			// if(ModelManager.instance.modelUser.building_cd.hasOwnProperty(this.mModel.id)){
			 	this.closeSelf();
			// }else{
			// 	updateSelf();				
			// }
			
		}

		private function onClick_quick(md:ModelBuiding):void{
			ViewManager.instance.showView(ConfigClass.VIEW_BUILDING_QUICKLY,md);
		}
	}

}