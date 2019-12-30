/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.hero_icon2UI;
	import ui.honour.itemHonourClgUI;

	public class honourChallengeUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var tInfo:Label;
		public var comHero:hero_icon2UI;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.honour.itemHonourClgUI",itemHonourClgUI);
			super.createChildren();
			loadUI("honour/honourChallenge");

		}

	}
}