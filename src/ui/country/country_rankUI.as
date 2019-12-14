/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.country.item_country_rank_new1UI;
	import ui.country.item_country_rank_newUI;

	public class country_rankUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var tab:Tab;
		public var mSelf:item_country_rank_new1UI;
		public var list:List;
		public var list_title:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.country.item_country_rank_new1UI",item_country_rank_new1UI);
			View.regComponent("ui.country.item_country_rank_newUI",item_country_rank_newUI);
			super.createChildren();
			loadUI("country/country_rank");

		}

	}
}