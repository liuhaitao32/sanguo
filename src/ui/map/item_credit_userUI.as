/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag2UI;
	import ui.com.hero_icon1UI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.bag.bagItemUI;

	public class item_credit_userUI extends ItemBase {
		public var indexLabel:Label;
		public var comCountry:country_flag2UI;
		public var comHead:hero_icon1UI;
		public var nameLabel:Label;
		public var comIndex:rank_inder_img_t_bigUI;
		public var comNum:Label;
		public var list:List;
		public var userBtn:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("map/item_credit_user");

		}

	}
}