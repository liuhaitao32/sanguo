/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_carouseUI extends ItemBase {
		public var panel:Panel;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/item_carouse");

		}

	}
}