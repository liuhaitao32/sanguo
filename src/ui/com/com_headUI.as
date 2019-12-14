/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class com_headUI extends ItemBase {
		public var icon0:Image;
		public var label0:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/com_head");

		}

	}
}