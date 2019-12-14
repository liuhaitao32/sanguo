/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon4UI;
	import ui.com.country_flag2UI;
	import ui.com.hero_power2UI;

	public class itemWorshipUI extends ItemBase {
		public var adImg:Image;
		public var btn:Button;
		public var boxGlow:Box;
		public var heroIcon:hero_icon4UI;
		public var bg1:Image;
		public var bg0:Image;
		public var bg2:Image;
		public var tName:Label;
		public var countryIcon:country_flag2UI;
		public var text0:Label;
		public var boxRank:Box;
		public var rank0:Image;
		public var rank1:Image;
		public var rank2:Image;
		public var comPower:hero_power2UI;
		public var box0:Box;
		public var tTeam:Label;
		public var text1:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon4UI",hero_icon4UI);
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("fight/itemWorship");

		}

	}
}