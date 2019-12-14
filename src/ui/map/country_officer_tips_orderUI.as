/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.btn_gotoUI;

	public class country_officer_tips_orderUI extends ViewPanel {
		public var heroIcon:hero_icon2UI;
		public var adImg:Image;
		public var lOfficer:Label;
		public var lName:Label;
		public var tName2:HTMLDivElement;
		public var btnGo:btn_gotoUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.btn_gotoUI",btn_gotoUI);
			super.createChildren();
			loadUI("map/country_officer_tips_order");

		}

	}
}