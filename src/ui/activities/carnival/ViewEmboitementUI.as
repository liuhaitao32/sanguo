/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.item_titleUI;

	public class ViewEmboitementUI extends ViewPanel {
		public var box:Box;
		public var panel:Panel;
		public var info:HTMLDivElement;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("activities/carnival/ViewEmboitement");

		}

	}
}