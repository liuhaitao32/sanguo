/**Created by the LayaAirIDE,do not modify.*/
package ui.arena {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.country_flag1UI;

	public class itemArenaUI extends ItemBase {
		public var tempImg:Image;
		public var imgAwaken:Image;
		public var comHero:hero_icon2UI;
		public var txtImg1:Image;
		public var imgDark1:Image;
		public var box:Box;
		public var comFlag:country_flag1UI;
		public var text0:Label;
		public var tNum:Label;
		public var tName:Label;
		public var imgLight:Image;
		public var tArena:Label;
		public var btn:Button;
		public var itemBox:Box;
		public var itemIcon:Image;
		public var tNum0:Label;
		public var buffBox:Box;
		public var tNum1:Label;
		public var askBtn:Button;
		public var tFight:Label;
		public var txtImg3:Image;
		public var tGuess:Label;
		public var tGuessTips:Label;
		public var imgDark0:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("arena/itemArena");

		}

	}
}