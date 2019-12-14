/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class hero_resolveUI extends ItemBase {
		public var heroStarBg:Image;
		public var imgAwaken:Image;
		public var comHero:hero_icon2UI;
		public var heroImg:Image;
		public var imgRatity:Image;
		public var selectImg:Image;
		public var raIcon:Image;
		public var nameLabel:Label;
		public var addLabel:Label;
		public var btnLock:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("com/hero_resolve");

		}

	}
}