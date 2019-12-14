/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon3UI;
	import ui.com.hero_starUI;
	import ui.com.img_c_txt_cUI;
	import ui.com.hero_power2UI;
	import ui.com.hero_lv1UI;

	public class itemUserHeroUI extends ItemBase {
		public var heroIcon:hero_icon3UI;
		public var heroStar:hero_starUI;
		public var heroType:img_c_txt_cUI;
		public var comPower:hero_power2UI;
		public var heroLv:hero_lv1UI;
		public var tName:Label;
		public var tGroup:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon3UI",hero_icon3UI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.img_c_txt_cUI",img_c_txt_cUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_lv1UI",hero_lv1UI);
			super.createChildren();
			loadUI("menu/itemUserHero");

		}

	}
}