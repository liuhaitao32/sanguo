/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon3UI;
	import ui.com.hero_lv3UI;

	public class item_country_alienUI extends ItemBase {
		public var comHero:hero_icon3UI;
		public var img1:Image;
		public var img2:Image;
		public var imgSelect:Image;
		public var heroLv:hero_lv3UI;
		public var textBox:Box;
		public var boxLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon3UI",hero_icon3UI);
			View.regComponent("ui.com.hero_lv3UI",hero_lv3UI);
			super.createChildren();
			loadUI("country/item_country_alien");

		}

	}
}