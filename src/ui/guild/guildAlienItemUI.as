/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon3UI;
	import ui.com.hero_lv3UI;

	public class guildAlienItemUI extends ItemBase {
		public var comHero:hero_icon3UI;
		public var img1:Image;
		public var img2:Image;
		public var boxLabel:Label;
		public var imgSelect:Image;
		public var heroLv:hero_lv3UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon3UI",hero_icon3UI);
			View.regComponent("ui.com.hero_lv3UI",hero_lv3UI);
			super.createChildren();
			loadUI("guild/guildAlienItem");

		}

	}
}