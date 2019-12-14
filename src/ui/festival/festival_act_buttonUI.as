/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class festival_act_buttonUI extends ItemBase {
		public var btn:Button;
		public var txt_name:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("festival/festival_act_button");

		}

	}
}