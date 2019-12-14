/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_flyUI extends ComPayType {
		public var img:Image;
		public var num:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/item_fly");

		}

	}
}