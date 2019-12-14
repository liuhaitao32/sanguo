/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.map.item_officer_listUI;
	import ui.com.item_titleUI;

	public class view_appoint_officerUI extends ViewPanel {
		public var tab:List;
		public var btn:Button;
		public var list:List;
		public var list_title:Box;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.map.item_officer_listUI",item_officer_listUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/view_appoint_officer");

		}

	}
}