/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.guild.guildAlienItemUI;
	import ui.com.hero_power2UI;
	import ui.com.hero_lv3UI;
	import laya.html.dom.HTMLDivElement;
	import ui.bag.bagItemUI;

	public class guildAlienUI extends ViewScenes {
		public var comHero:hero_icon2UI;
		public var text0:Label;
		public var timerLabel:Label;
		public var list:List;
		public var boxTop:Box;
		public var btnTeam:Button;
		public var nameLabel:Label;
		public var comPower:hero_power2UI;
		public var heroLv:hero_lv3UI;
		public var boxMid:Box;
		public var text1:Label;
		public var htmlLabel:HTMLDivElement;
		public var btnJoin:Button;
		public var weakList:List;
		public var boxCheck:Box;
		public var btnSelet:Button;
		public var autoLabel:Label;
		public var btnSelet2:Button;
		public var text3:Label;
		public var box3:Box;
		public var box1:Box;
		public var box2:Box;
		public var box0:Box;
		public var text2:Label;
		public var rewardList:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.guild.guildAlienItemUI",guildAlienItemUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_lv3UI",hero_lv3UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("guild/guildAlien");

		}

	}
}