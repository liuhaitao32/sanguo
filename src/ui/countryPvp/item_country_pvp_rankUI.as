/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.country_flag2UI;
	import ui.bag.bagItemUI;

	public class item_country_pvp_rankUI extends ItemBase {
		public var cRank:rank_inder_img_t_bigUI;
		public var tName:Label;
		public var cFlag:country_flag2UI;
		public var tNum:Label;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("countryPvp/item_country_pvp_rank");

		}

	}
}