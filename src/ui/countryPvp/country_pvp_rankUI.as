/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.countryPvp.item_country_pvp_rank1UI;
	import ui.countryPvp.item_country_pvp_rankUI;
	import ui.com.item_title_sUI;

	public class country_pvp_rankUI extends ItemBase {
		public var cItem:item_country_pvp_rank1UI;
		public var list:List;
		public var cTitle:item_title_sUI;
		public var text01:Label;
		public var text02:Label;
		public var text03:Label;
		public var text04:Label;
		public var bAsk:Button;
		public var Ttips:Label;
		public var tTips:Label;

		override protected function createChildren():void {
			View.regComponent("ui.countryPvp.item_country_pvp_rank1UI",item_country_pvp_rank1UI);
			View.regComponent("ui.countryPvp.item_country_pvp_rankUI",item_country_pvp_rankUI);
			View.regComponent("ui.com.item_title_sUI",item_title_sUI);
			super.createChildren();
			loadUI("countryPvp/country_pvp_rank");

		}

	}
}