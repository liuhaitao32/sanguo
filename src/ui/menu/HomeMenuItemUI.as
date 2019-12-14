/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class HomeMenuItemUI extends ItemBase {
		public var item_btn:Button;
		public var imgWork:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("menu/HomeMenuItem");

		}

	}
}