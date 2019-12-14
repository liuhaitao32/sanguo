/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.country_flag1UI;

	public class itemPKcountryUI extends ItemBase {
		public var heroIcon:hero_icon1UI;
		public var country:country_flag1UI;
		public var diming:Label;
		public var tName:Label;
		public var tIndex:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("fight/itemPKcountry");

		}

	}
}