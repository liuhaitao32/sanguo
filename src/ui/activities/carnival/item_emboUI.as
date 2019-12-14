/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class item_emboUI extends ItemBase {
		public var icon:bagItemUI;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/carnival/item_embo");

		}

	}
}