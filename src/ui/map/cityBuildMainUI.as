/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.btn_icon_txtUI;
	import ui.map.item_city_buildUI;
	import ui.com.item_titleUI;

	public class cityBuildMainUI extends ViewPanel {
		public var btn:btn_icon_txtUI;
		public var tab:Tab;
		public var itemList:List;
		public var boxCondition:Box;
		public var text0:Label;
		public var conditionList:List;
		public var infoLabel:Label;
		public var btnChange:Button;
		public var effcetPanel:Panel;
		public var effcetBox:Box;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.map.item_city_buildUI",item_city_buildUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/cityBuildMain");

		}

	}
}