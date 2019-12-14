/**Created by the LayaAirIDE,do not modify.*/
package ui.chat {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class chatFaceUI extends ItemBase {
		public var list:List;
		public var tab:Tab;
		public var btn_close:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("chat/chatFace");

		}

	}
}