/**Created by the LayaAirIDE,do not modify.*/
package ui.chat {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_chatUI extends ItemBase {

		override protected function createChildren():void {
			super.createChildren();
			loadUI("chat/item_chat");

		}

	}
}