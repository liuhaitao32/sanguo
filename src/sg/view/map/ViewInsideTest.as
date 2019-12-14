package sg.view.map
{
	import ui.test.TestInsideUI;
	import laya.utils.Handler;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.ui.Button;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.model.ModelInside;
	import sg.model.ModelBuiding;
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigClass;
	import avmplus.factoryXml;
	import sg.model.ModelEquip;
	import sg.net.NetSocket;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import laya.maths.MathUtil;
	import ui.com.building_tips1UI;

	/**
	 * ...
	 * @author
	 */
	public class ViewInsideTest extends TestInsideUI{
		public function ViewInsideTest(){
			//
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_SET,this,this.on_building_set);
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_UPDATE_CD,this,this.on_building_set);
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_UPDATE_END,this,this.on_building_set);
			//
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_GIFT_PRODUCE_OK,this,this.on_building_set);
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_GIFT_PRODUCE_READY,this,this.on_building_set);
			//
			ModelManager.instance.modelInside.on(ModelInside.EQUIP_UPDATE_CD,this,this.on_building_set_building002);
			ModelManager.instance.modelInside.on(ModelInside.EQUIP_UPDATE_GET,this,this.on_building_set_building002);
			//
			ModelManager.instance.modelInside.on(ModelInside.ARMY_BUILDING_TRAIN_UPDATE_CD,this,this.on_building_set);
			ModelManager.instance.modelInside.on(ModelInside.ARMY_BUILDING_TRAIN_GET,this,this.on_building_set);
			//
			// var bName:String = "官邸,珍宝阁,军府,辎重站,酒馆,书院,演武场,武馆,弓兵营,方士营,骑兵营,步兵营,铸币厂1,铸币厂2,铸币厂3,冶炼厂1,冶炼厂2,冶炼厂3,锯木厂1,锯木厂2,锯木厂3,农庄1,农庄2,农庄3";
			// var nameArr:Array = bName.split(",");
			// var arr:Array = [];
			// var buildingAll:Object = ModelBuiding.buildingModels;
			// var element:ModelBuiding;
			// //
			// var i:int = 0;
			// //
			// for(var key:String in buildingAll)
			// {
			// 	element = buildingAll[key];
			// 	arr.push(element);
			// }
			// arr.sort(MathUtil.sortByKey("id",false,false));
			// var len:int = arr.length;
			// for(i = 0; i < len; i++)
			// {
			// 	element = arr[i];
			// 	element.index = i;
			// }
			// //
			// this.list.renderHandler = new Handler(this,this.list_render);
			// this.list.array = arr;
		}
		private function list_render(building:Box,index:int):void{
			var runt:Number = Laya.timer.currTimer;//new Date().getTime();
			//
			var md:ModelBuiding = this.list.array[index] as ModelBuiding;
			//
			var islv0:Boolean = md.checkIslv0toUnlock();
			var canUseArr:Boolean = ModelManager.instance.modelInside.checkBuilderArrCanUse();
			//
			var upArr:Array = md.checkCDupgradeIsOK(md.lvNext());
			//
			// (building.getChildByName("t_btn") as Button).label = md.getName();
			// (building.getChildByName("t_btn") as Button).labelColors = "#000000";
			(building.getChildByName("tlv") as Label).text = md.getName()+" "+md.lv+"";
			(building.getChildByName("t_status") as Label).text = md.id + " "+canUseArr +" "+upArr[0]+" "+upArr[1];
			(building.getChildByName("t_status") as Label).color = (upArr[0] && upArr[1])?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO;
			
			var status:int = -1;
			this.checkBuildingStatusShowUI(building,md);
			//
			(building.getChildByName("t_btn") as Button).off(Event.CLICK,this,this.click);
			(building.getChildByName("t_btn") as Button).on(Event.CLICK,this,this.click,[md,status,0]);
			// //
			(building.getChildByName("t_info") as Button).off(Event.CLICK,this,this.click_info);
			(building.getChildByName("t_info") as Button).on(Event.CLICK,this,this.click_info,[md,status]);
			// //
			(building.getChildByName("t_make") as Button).off(Event.CLICK,this,this.click);
			(building.getChildByName("t_make") as Button).on(Event.CLICK,this,this.click,[md,status,2]);
			// //
			(building.getChildByName("t_up") as Button).off(Event.CLICK,this,this.click);
			(building.getChildByName("t_up") as Button).on(Event.CLICK,this,this.click,[md,status,3]);
			//		
			(building.getChildByName("t_wendao") as Button).off(Event.CLICK,this,this.click);
			(building.getChildByName("t_wendao") as Button).on(Event.CLICK,this,this.click,[md,status,4]);	

			// var re:Object = md.checkMyStatus();		
			// if(re.hasOwnProperty("get")){
				// var bbbbb:building_tips1UI = new building_tips1UI();
				// bbbbb.setBuildingTipsIcon("");
				// building.addChild(bbbbb);
			// }
		}
		private function checkBuildingStatusShowUI(building:Box,bmd:ModelBuiding):void{
			var arr:Array = ModelManager.instance.modelInside.checkBuildingView(bmd,true);
			//
			var btn:Button = building.getChildByName("t_btn") as Button;
			var info:Button = building.getChildByName("t_info") as Button;
			var make:Button = building.getChildByName("t_make") as Button;
			var up:Button = building.getChildByName("t_up") as Button;
			var wendao:Button = building.getChildByName("t_wendao") as Button;
			// //
			btn.visible = arr[0].visible;
			info.visible = arr[1].visible;
			make.visible = arr[2].visible;
			up.visible = arr[3].visible;
			wendao.visible = arr[4].visible;
			//
			btn.label = arr[0].label;
			info.label = arr[1].label;
			make.label = arr[2].label;
			up.label = arr[3].label;
			wendao.label = arr[4].label;	
			//
			if(bmd.produce>=0 && bmd.lv>0){//
				//检查是否有产出
				var gifts:Number = bmd.getMyGift(bmd.lv);
				if(gifts>0 && !bmd.isUpgradeIng()){
					(building.getChildByName("t_status") as Label).text = Tools.getMsgById("msg_ViewInsideTest_0")+gifts;
					(building.getChildByName("t_btn") as Button).labelColors = "#FF0000";
				}
			}
		}
		private function click(md:ModelBuiding,status:int,btnType:int):void{
			ModelManager.instance.modelInside.checkBuildingFunc(md,btnType);
		}
		private function click_info(md:ModelBuiding):void{
			ViewManager.instance.showView(ConfigClass.VIEW_BUILDING_INFO,md);
		}
		private function on_building_set(data:ModelBuiding):void{
			this.list.changeItem(data.index,data);
		}
		private function on_building_set_building002(emd:*):void{
			var bmd:ModelBuiding = ModelManager.instance.modelInside.getBuildingModel("building002");
			this.list.changeItem(bmd.index,bmd);
		}
	}
}