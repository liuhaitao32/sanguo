/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.img_c_txt_cUI;
	import ui.com.hero_starUI;
	import ui.com.army_icon2UI;
	import ui.com.payTypeUI;

	public class shogunHeroItemUI extends ItemBase {
		public var box0:Box;
		public var imgRatity:Image;
		public var upBtn:Button;
		public var downBtn:Button;
		public var comHeroIcon:hero_icon1UI;
		public var comHeroType:img_c_txt_cUI;
		public var comHeroStar:hero_starUI;
		public var rankImg:Image;
		public var scoreLabel:Label;
		public var text0:Label;
		public var upBox:Box;
		public var shogunLabel:Label;
		public var text4:Label;
		public var lvLabel:Label;
		public var nameLabel:Label;
		public var limitLabel:Label;
		public var tArmy0:Label;
		public var tArmy1:Label;
		public var army0:army_icon2UI;
		public var army1:army_icon2UI;
		public var box1:Box;
		public var box1Label:Label;
		public var box1Com:payTypeUI;
		public var text1:Label;
		public var boxMid:Box;
		public var box3:Box;
		public var box3Text:Label;
		public var text2:Label;
		public var box2:Box;
		public var box2Text:Label;
		public var text3:Label;
		public var itemBtn:Button;
		public var imgSelected:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.img_c_txt_cUI",img_c_txt_cUI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.army_icon2UI",army_icon2UI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("inside/shogunHeroItem");

		}

	}
}