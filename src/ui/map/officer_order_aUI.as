/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.hero_icon2UI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.btn_icon_txtUI;
	import ui.com.item_titleUI;

	public class officer_order_aUI extends ViewPanel {
		public var mBox:Box;
		public var adImg:Image;
		public var heroIcon:hero_icon2UI;
		public var imgOrder:Image;
		public var tName:Label;
		public var text0:Label;
		public var tInfo:HTMLDivElement;
		public var tMerit:Label;
		public var text1:Label;
		public var btn_coin:btn_icon_txtUI;
		public var btn_free:Button;
		public var tTips:HTMLDivElement;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/officer_order_a");

		}

	}
}