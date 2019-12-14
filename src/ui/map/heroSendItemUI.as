/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.hero_starUI;
	import ui.com.img_c_txt_cUI;
	import ui.com.army_icon2UI;
	import ui.com.hero_power2UI;
	import ui.com.hero_lv2UI;

	public class heroSendItemUI extends ItemBase {
		public var box:Box;
		public var heroIcon:hero_icon1UI;
		public var bar0:ProgressBar;
		public var bar1:ProgressBar;
		public var tName:Label;
		public var tArmyNum0:Label;
		public var tArmyNum1:Label;
		public var army0:Label;
		public var army1:Label;
		public var heroStar:hero_starUI;
		public var heroType:img_c_txt_cUI;
		public var armyIcon0:army_icon2UI;
		public var armyIcon1:army_icon2UI;
		public var comPower:hero_power2UI;
		public var heroLv:hero_lv2UI;
		public var select:Image;
		public var powerFalse:Label;
		public var tStatus:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.img_c_txt_cUI",img_c_txt_cUI);
			View.regComponent("ui.com.army_icon2UI",army_icon2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_lv2UI",hero_lv2UI);
			super.createChildren();
			loadUI("map/heroSendItem");

		}

	}
}