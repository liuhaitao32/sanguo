/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class dialog_txt_yes_noUI extends ViewPanel {
		public var label:Label;
		public var btn_yes:Button;
		public var btn_no:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/dialog_txt_yes_no");

		}

	}
}