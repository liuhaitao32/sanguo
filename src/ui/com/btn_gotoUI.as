/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.display.Text;

	public class btn_gotoUI extends ComPayType {

		override protected function createChildren():void {
			View.regComponent("Text",Text);
			super.createChildren();
			loadUI("com/btn_goto");

		}

	}
}