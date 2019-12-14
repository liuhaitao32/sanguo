/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.img_c_txt_cUI;
	import ui.com.hero_starUI;
	import ui.com.hero_lv2UI;
	import ui.com.army_icon2UI;
	import ui.com.hero_power2UI;

	public class itemTroopUI extends ItemBase {
		public var all:Box;
		public var heroIcon:hero_icon1UI;
		public var heroType:img_c_txt_cUI;
		public var heroStar:hero_starUI;
		public var heroLv:hero_lv2UI;
		public var barArmy0:ProgressBar;
		public var barArmy1:ProgressBar;
		public var boxState:Box;
		public var tIndex:Label;
		public var select:Image;
		public var select2:Image;
		public var tArmyNum0:Label;
		public var tArmyNum1:Label;
		public var tName:Label;
		public var tArmy0:Label;
		public var tArmy1:Label;
		public var army0:army_icon2UI;
		public var army1:army_icon2UI;
		public var comPower:hero_power2UI;
		public var tPowerInfo:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.img_c_txt_cUI",img_c_txt_cUI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.hero_lv2UI",hero_lv2UI);
			View.regComponent("ui.com.army_icon2UI",army_icon2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("fight/itemTroop");

		}

	}
}