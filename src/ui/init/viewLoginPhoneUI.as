/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class viewLoginPhoneUI extends ViewPanel {
		public var btn_login:Button;
		public var txtNumber:TextInput;
		public var text3:Label;
		public var txtCode:TextInput;
		public var btn_code:Button;
		public var text1:Label;
		public var text0:Label;
		public var text2:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/viewLoginPhone");

		}

	}
}