/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.country_flag1UI;

	public class itemChampion8UI extends ItemBase {
		public var bg1:Image;
		public var bg0:Image;
		public var boxGlow:Box;
		public var boxTag:Box;
		public var tInfo:Label;
		public var heroIcon:hero_icon1UI;
		public var tName:Label;
		public var betImg:Image;
		public var mCountry:country_flag1UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("fight/itemChampion8");

		}

	}
}