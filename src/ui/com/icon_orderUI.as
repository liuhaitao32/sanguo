/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class icon_orderUI extends ItemBase {
		public var iIcon:Image;
		public var tBox:Box;
		public var tTime:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/icon_order");

		}

	}
}