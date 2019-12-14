/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.dial {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;

	public class dialRecordUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var panel:Panel;
		public var text0:Label;
		public var info:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("activities/dial/dialRecord");

		}

	}
}