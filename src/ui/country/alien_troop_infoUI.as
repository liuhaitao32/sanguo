/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.country.item_alien_troop_infoUI;
	import ui.com.item_titleUI;

	public class alien_troop_infoUI extends ViewPanel {
		public var text0:Label;
		public var btn1:Button;
		public var btn2:Button;
		public var numLabel:Label;
		public var text1:Label;
		public var list:List;
		public var comTitle:item_titleUI;
		public var text2:Label;
		public var timerLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.country.item_alien_troop_infoUI",item_alien_troop_infoUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("country/alien_troop_info");

		}

	}
}