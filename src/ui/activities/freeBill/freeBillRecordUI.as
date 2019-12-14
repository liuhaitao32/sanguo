/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.freeBill {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;

	public class freeBillRecordUI extends ViewPanel {
		public var box:Box;
		public var container_info:Panel;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("activities/freeBill/freeBillRecord");

		}

	}
}