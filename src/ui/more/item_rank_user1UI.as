/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag2UI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.hero_power2UI;

	public class item_rank_user1UI extends ItemBase {
		public var comCountry:country_flag2UI;
		public var nameLabel:Label;
		public var comIndex:rank_inder_img_t_bigUI;
		public var boxLv:Box;
		public var lvLabel:Label;
		public var numLabel:Label;
		public var comPower:hero_power2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("more/item_rank_user1");

		}

	}
}