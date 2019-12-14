/**Created by the LayaAirIDE,do not modify.*/
package ui.mail {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class searchUserUI extends ViewPanel {
		public var tName:TextInput;
		public var text0:Label;
		public var titleLabel:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mail/searchUser");

		}

	}
}