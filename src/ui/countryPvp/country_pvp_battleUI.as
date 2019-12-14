/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.item_title_sUI;
	import ui.countryPvp.item_country_pvp_countryUI;

	public class country_pvp_battleUI extends ItemBase {
		public var cTitle:item_title_sUI;
		public var list:List;
		public var tLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.item_title_sUI",item_title_sUI);
			View.regComponent("ui.countryPvp.item_country_pvp_countryUI",item_country_pvp_countryUI);
			super.createChildren();
			loadUI("countryPvp/country_pvp_battle");

		}

	}
}