/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.item_titleUI;

	public class buildingInfoUI extends ViewPanel {
		public var bIcon:Box;
		public var tInfo:Label;
		public var tLv:Label;
		public var tInfo2:HTMLDivElement;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/buildingInfo");

		}

	}
}