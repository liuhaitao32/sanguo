/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.more.item_moreUI;
	import ui.com.item_titleUI;

	public class more_mainUI extends ViewPanel {
		public var list:List;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.more.item_moreUI",item_moreUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("more/more_main");

		}

	}
}