/**Created by the LayaAirIDE,do not modify.*/
package ui.equip {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.inside.equipItemUI;
	import ui.com.item_titleUI;
	import ui.equip.itemEquipTabUI;
	import ui.com.hero_icon_equipUI;

	public class equipMainUI extends ViewPanel {
		public var equipList:List;
		public var comTitle:item_titleUI;
		public var tabList:List;
		public var tTypeName:Label;
		public var tTypeNum:Label;
		public var comEquip:hero_icon_equipUI;
		public var tEname:Label;
		public var tUname:Label;
		public var mBox:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.inside.equipItemUI",equipItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.equip.itemEquipTabUI",itemEquipTabUI);
			View.regComponent("ui.com.hero_icon_equipUI",hero_icon_equipUI);
			super.createChildren();
			loadUI("equip/equipMain");

		}

	}
}