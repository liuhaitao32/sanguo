/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.hero_icon1UI;
	import ui.com.country_flag1UI;

	public class item_country_pvp_killUI extends ItemBase {
		public var cRank:rank_inder_img_t_bigUI;
		public var tName:Label;
		public var tNum:Label;
		public var cHead:hero_icon1UI;
		public var cFlag:country_flag1UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("countryPvp/item_country_pvp_kill");

		}

	}
}