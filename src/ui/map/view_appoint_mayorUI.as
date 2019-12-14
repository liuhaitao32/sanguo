/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.map.item_mayor_listUI;
	import ui.com.item_titleUI;

	public class view_appoint_mayorUI extends ViewPanel {
		public var btnGo:Button;
		public var tab:Tab;
		public var list:List;
		public var tName:Label;
		public var tType:Label;
		public var tNum:Label;
		public var tMayor:Label;
		public var list_title:Box;
		public var comTitle:item_titleUI;
		public var timerLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.map.item_mayor_listUI",item_mayor_listUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/view_appoint_mayor");

		}

	}
}