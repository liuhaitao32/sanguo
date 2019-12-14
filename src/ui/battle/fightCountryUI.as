/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag2UI;

	public class fightCountryUI extends ItemBase {
		public var bg0:Image;
		public var bg1:Image;
		public var barBox:Sprite;
		public var country0:country_flag2UI;
		public var country1:country_flag2UI;
		public var num0:Label;
		public var num1:Label;
		public var fightIndex:Label;
		public var tDmg0:Label;
		public var tRes0:Label;
		public var tDmg1:Label;
		public var tRes1:Label;
		public var imgTower0:Image;
		public var tLv0:Label;
		public var imgTower1:Image;
		public var tLv1:Label;
		public var boxTower1:Box;
		public var imgCount1:Image;
		public var tTower1:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			super.createChildren();
			loadUI("battle/fightCountry");

		}

	}
}