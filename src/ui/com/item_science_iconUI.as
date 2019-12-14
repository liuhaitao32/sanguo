/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_science_iconUI extends ComPayType {
		public var img:Image;
		public var imgMask:Image;
		public var bg:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/item_science_icon");

		}

	}
}