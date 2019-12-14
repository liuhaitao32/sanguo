/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.map.item_credit_gift_dayUI;
	import ui.com.country_flag2UI;
	import ui.com.hero_icon1UI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class creditGift1UI extends ViewPanel {
		public var dayList:List;
		public var comUser:Image;
		public var comCountry:country_flag2UI;
		public var comHead:hero_icon1UI;
		public var comIndex:rank_inder_img_t_bigUI;
		public var nameLabel:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.map.item_credit_gift_dayUI",item_credit_gift_dayUI);
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/creditGift1");

		}

	}
}