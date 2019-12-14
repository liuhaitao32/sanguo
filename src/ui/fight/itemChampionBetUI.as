/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.hero_power2UI;
	import ui.com.country_flag1UI;

	public class itemChampionBetUI extends ItemBase {
		public var adImg:Image;
		public var btn:Button;
		public var heroIcon:hero_icon2UI;
		public var tName:Label;
		public var tNum:Label;
		public var tBet:Label;
		public var text0:Label;
		public var text1:Label;
		public var comPower:hero_power2UI;
		public var mCountry:country_flag1UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("fight/itemChampionBet");

		}

	}
}