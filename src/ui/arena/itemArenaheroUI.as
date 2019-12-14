/**Created by the LayaAirIDE,do not modify.*/
package ui.arena {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.img_c_txt_cUI;
	import ui.com.hero_starUI;
	import ui.com.hero_lv2UI;
	import ui.com.hero_power2UI;

	public class itemArenaheroUI extends ItemBase {
		public var mHave:Box;
		public var colorBg:Image;
		public var tName:Label;
		public var heroIcon:hero_icon1UI;
		public var heroType:img_c_txt_cUI;
		public var heroStar:hero_starUI;
		public var heroLv:hero_lv2UI;
		public var armyPro:ProgressBar;
		public var comPower:hero_power2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.img_c_txt_cUI",img_c_txt_cUI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.hero_lv2UI",hero_lv2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("arena/itemArenahero");

		}

	}
}