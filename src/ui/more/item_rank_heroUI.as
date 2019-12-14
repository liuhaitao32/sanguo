/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.country_flag1UI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.skillItemUI;
	import ui.com.hero_starUI;
	import ui.com.hero_power2UI;
	import ui.com.hero_lv1UI;

	public class item_rank_heroUI extends ItemBase {
		public var comHero:hero_icon1UI;
		public var comCountry:country_flag1UI;
		public var comIndex:rank_inder_img_t_bigUI;
		public var list:List;
		public var hnameLabel:Label;
		public var unameLabel:Label;
		public var comStar:hero_starUI;
		public var comPower:hero_power2UI;
		public var heroLv:hero_lv1UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.skillItemUI",skillItemUI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_lv1UI",hero_lv1UI);
			super.createChildren();
			loadUI("more/item_rank_hero");

		}

	}
}