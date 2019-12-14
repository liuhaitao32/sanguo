/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon_equipUI;

	public class effect_equip_upgradeUI extends ComPayType {
		public var bgImg:Image;
		public var tTitle:Image;
		public var tName:Label;
		public var tType:Label;
		public var mIcon:hero_icon_equipUI;
		public var tInfo:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon_equipUI",hero_icon_equipUI);
			super.createChildren();
			loadUI("com/effect_equip_upgrade");

		}

	}
}