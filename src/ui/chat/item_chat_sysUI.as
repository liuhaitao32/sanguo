/**Created by the LayaAirIDE,do not modify.*/
package ui.chat {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class item_chat_sysUI extends ItemBase {
		public var textLabel:HTMLDivElement;
		public var btnChannel:Button;
		public var timeLabel:Label;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("chat/item_chat_sys");

		}

	}
}