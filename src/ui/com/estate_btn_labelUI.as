/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class estate_btn_labelUI extends ItemBase {
		public var btn:Button;
		public var img:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/estate_btn_label");

		}

	}
}