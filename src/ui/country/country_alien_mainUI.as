/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.hero_power2UI;
	import ui.com.hero_lv3UI;
	import ui.country.item_country_alienUI;
	import laya.html.dom.HTMLDivElement;
	import ui.bag.bagItemUI;

	public class country_alien_mainUI extends ItemBase {
		public var comHero:hero_icon2UI;
		public var nameLabel:Label;
		public var comPower:hero_power2UI;
		public var askBtn:Button;
		public var heroLv:hero_lv3UI;
		public var text0:Label;
		public var timerLabel:Label;
		public var list:List;
		public var comLow:Label;
		public var text1:Label;
		public var imgText:Image;
		public var html:HTMLDivElement;
		public var btn:Button;
		public var weakList:List;
		public var html2:HTMLDivElement;
		public var text2:Label;
		public var rewardList:List;
		public var text3:Label;
		public var rewardBox0:Box;
		public var rewardBox1:Box;
		public var rewardBox2:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_lv3UI",hero_lv3UI);
			View.regComponent("ui.country.item_country_alienUI",item_country_alienUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("country/country_alien_main");

		}

	}
}