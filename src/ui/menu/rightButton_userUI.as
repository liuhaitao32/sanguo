/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class rightButton_userUI extends ItemBase {
		public var btn:Button;
		public var txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("menu/rightButton_user");

		}

	}
}