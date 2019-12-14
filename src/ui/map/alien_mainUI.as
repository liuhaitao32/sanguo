/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.hero_icon2UI;
	import ui.com.hero_power2UI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class alien_mainUI extends ViewPanel {
		public var adImg:Image;
		public var heroIcon:hero_icon2UI;
		public var diffBg:Image;
		public var tType:Label;
		public var tName:Label;
		public var tLv:Label;
		public var tArmy:Label;
		public var tLvName:Label;
		public var tArmyName:Label;
		public var tPowerName:Label;
		public var comPower:hero_power2UI;
		public var btn:Button;
		public var list:List;
		public var tRewardTitle:Label;
		public var tRewardInfo:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/alien_main");

		}

	}
}