/**Created by the LayaAirIDE,do not modify.*/
package ui.mail {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.item_titleUI;

	public class addChatUI extends ViewPanel {
		public var inputLabel:TextInput;
		public var btn0:Button;
		public var btn1:Button;
		public var text0:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("mail/addChat");

		}

	}
}