/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.hero_power2UI;

	public class itemChampionHero1UI extends ItemBase {
		public var mHave:Box;
		public var heroIcon:hero_icon1UI;
		public var tName:Label;
		public var tIndex:Label;
		public var comPower:hero_power2UI;
		public var mNo:Box;
		public var mLock:Image;
		public var mAdd:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("fight/itemChampionHero1");

		}

	}
}