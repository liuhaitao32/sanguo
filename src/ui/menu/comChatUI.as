/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.menu.itemChatUI;

	public class comChatUI extends ItemBase {
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.menu.itemChatUI",itemChatUI);
			super.createChildren();
			loadUI("menu/comChat");

		}

	}
}