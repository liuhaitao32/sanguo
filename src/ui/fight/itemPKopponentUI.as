/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;
	import ui.com.hero_icon3UI;
	import ui.com.hero_power2UI;

	public class itemPKopponentUI extends ItemBase {
		public var mCountry:country_flag1UI;
		public var heroIcon:hero_icon3UI;
		public var btnClear:Button;
		public var btn:Button;
		public var text0:Label;
		public var tName:Label;
		public var tIndex:Label;
		public var comPower:hero_power2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("ui.com.hero_icon3UI",hero_icon3UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("fight/itemPKopponent");

		}

	}
}