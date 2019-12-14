/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.hero_icon2UI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.btn_icon_txt_sureUI;

	public class country_impeachUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var comHero:hero_icon2UI;
		public var infoBox:Box;
		public var infoLabel:HTMLDivElement;
		public var box1:Box;
		public var title1:Label;
		public var info1:Label;
		public var btn1:Button;
		public var title0:Label;
		public var info0:Label;
		public var btn0:Button;
		public var text0:Label;
		public var box0:Box;
		public var btnImp:btn_icon_txt_sureUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("country/country_impeach");

		}

	}
}