/**Created by the LayaAirIDE,do not modify.*/
package ui.explore {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class fight_reportUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var tab:Tab;
		public var list:List;
		public var txt_hint:Label;
		public var box_hint:Box;
		public var txt_msg:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("explore/fight_report");

		}

	}
}