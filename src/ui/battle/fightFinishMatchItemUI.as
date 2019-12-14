/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_starUI;
	import ui.com.hero_icon1UI;
	import ui.com.hero_lv2UI;

	public class fightFinishMatchItemUI extends ItemBase {
		public var mHave:Box;
		public var img:Image;
		public var box:Box;
		public var heroStar:hero_starUI;
		public var tName:Label;
		public var tHp:Label;
		public var tArmy:Label;
		public var heroIcon:hero_icon1UI;
		public var heroLv:hero_lv2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.hero_lv2UI",hero_lv2UI);
			super.createChildren();
			loadUI("battle/fightFinishMatchItem");

		}

	}
}