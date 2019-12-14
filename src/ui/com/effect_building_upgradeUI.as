/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.building_info_lvUI;
	import ui.com.building_info_infoUI;

	public class effect_building_upgradeUI extends ComPayType {
		public var tName:Image;
		public var tBase:Image;
		public var adImg:Image;
		public var baseBox:Box;
		public var iBase:Image;
		public var tBaseLv:Label;
		public var tBaseTips1:Label;
		public var bBox:building_info_lvUI;
		public var bBoxInfo:building_info_infoUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.building_info_lvUI",building_info_lvUI);
			View.regComponent("ui.com.building_info_infoUI",building_info_infoUI);
			super.createChildren();
			loadUI("com/effect_building_upgrade");

		}

	}
}