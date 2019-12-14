/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class effect_equip_enhanceUI extends ComPayType {
		public var tTitle:Image;
		public var tText:Label;
		public var comEquip:bagItemUI;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("com/effect_equip_enhance");

		}

	}
}