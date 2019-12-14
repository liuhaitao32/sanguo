/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.country_flag2UI;
	import ui.com.hero_icon1UI;

	public class item_credit_gift_dayUI extends ItemBase {
		public var list:List;
		public var comIndex:rank_inder_img_t_bigUI;
		public var comNum:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("map/item_credit_gift_day");

		}

	}
}