/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_bagUI extends ItemBase {
		public var icon:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/item_bag");

		}

	}
}