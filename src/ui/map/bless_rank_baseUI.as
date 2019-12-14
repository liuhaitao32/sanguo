/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.country_flag2UI;

	public class bless_rank_baseUI extends ItemBase {
		public var item_rank:rank_inder_img_t_bigUI;
		public var txt_name:Label;
		public var txt_time:Label;
		public var txt_hurt:Label;
		public var icon_country:country_flag2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			super.createChildren();
			loadUI("map/bless_rank_base");

		}

	}
}