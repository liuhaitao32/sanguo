/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.hero_icon2UI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.item_titleUI;

	public class country_officer_infoUI extends ViewPanel {
		public var adImg:Image;
		public var heroIcon:hero_icon2UI;
		public var btn:Button;
		public var tStatus:Label;
		public var tOpen:Label;
		public var tInfo:HTMLDivElement;
		public var box0:Box;
		public var tTips:Label;
		public var imgName:Image;
		public var tOfficer:Label;
		public var tName:Label;
		public var tOnline:Label;
		public var impBtn:Button;
		public var box1:Box;
		public var tMsg:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/country_officer_info");

		}

	}
}