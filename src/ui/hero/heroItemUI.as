/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.hero_starUI;
	import ui.com.hero_lv2UI;

	public class heroItemUI extends ItemBase {
		public var box_hero:Box;
		public var heroStarBg:Image;
		public var imgAwaken:Image;
		public var heroIcon:hero_icon2UI;
		public var imgRarity:Image;
		public var tName:Label;
		public var boxReady:Box;
		public var barItem:ProgressBar;
		public var tItem:Label;
		public var itemNum:Box;
		public var tItemNum:Label;
		public var boxStar:hero_starUI;
		public var heroLv:hero_lv2UI;
		public var mTitle:Image;
		public var tTitle:Label;
		public var clipGet:Image;
		public var imgNew:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.hero_lv2UI",hero_lv2UI);
			super.createChildren();
			loadUI("hero/heroItem");

		}

	}
}