/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon_equipUI;

	public class heroEquipItemUI extends ItemBase {
		public var com:hero_icon_equipUI;
		public var tEquipped:Label;
		public var tName:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon_equipUI",hero_icon_equipUI);
			super.createChildren();
			loadUI("hero/heroEquipItem");

		}

	}
}