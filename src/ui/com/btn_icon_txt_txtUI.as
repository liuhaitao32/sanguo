/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class btn_icon_txt_txtUI extends ComPayType {
		public var textlabel:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/btn_icon_txt_txt");

		}

	}
}