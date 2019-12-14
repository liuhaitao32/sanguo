/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag2UI;
	import ui.com.rank_inder_img_t_bigUI;

	public class item_rank_guildUI extends ItemBase {
		public var comCountry:country_flag2UI;
		public var nameLabel:Label;
		public var memberLabel:Label;
		public var killLabel:Label;
		public var comIndex:rank_inder_img_t_bigUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			super.createChildren();
			loadUI("more/item_rank_guild");

		}

	}
}