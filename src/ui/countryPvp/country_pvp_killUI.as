/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.countryPvp.item_country_pvp_killUI;

	public class country_pvp_killUI extends ViewPanel {
		public var cTitle:item_titleUI;
		public var list:List;
		public var text0:Label;
		public var text1:Label;
		public var text2:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.countryPvp.item_country_pvp_killUI",item_country_pvp_killUI);
			super.createChildren();
			loadUI("countryPvp/country_pvp_kill");

		}

	}
}