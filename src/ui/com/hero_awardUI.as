/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.hero_icon1UI;

	public class hero_awardUI extends ItemBase {
		public var heroBg:Image;
		public var bigHero:hero_icon2UI;
		public var imgRa:Image;
		public var cardBG:Image;
		public var box:Box;
		public var pro:ProgressBar;
		public var nameLabel:Label;
		public var barLabel:Label;
		public var addLabel:Label;
		public var heroImg:hero_icon1UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("com/hero_award");

		}

	}
}