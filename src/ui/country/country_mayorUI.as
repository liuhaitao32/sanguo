/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.country.item_country_mayor_newUI;

	public class country_mayorUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var list:List;
		public var btn0:Button;
		public var btn1:Button;
		public var btn2:Button;
		public var btn3:Button;
		public var tabs0:Button;
		public var tabs1:Button;
		public var info0:Label;
		public var info1:Label;
		public var text0:Label;
		public var text1:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.country.item_country_mayor_newUI",item_country_mayor_newUI);
			super.createChildren();
			loadUI("country/country_mayor");

		}

	}
}