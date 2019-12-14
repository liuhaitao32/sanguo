/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.dial {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class item_dialUI extends ItemBase {
		public var com:bagItemUI;
		public var nameLabel:Label;
		public var imgGet:Image;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/dial/item_dial");

		}

	}
}