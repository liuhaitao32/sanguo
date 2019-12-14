/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import sg.view.com.sgCloseBtn;

	public class panel_bg_btn_sUI extends ItemBase {

		override protected function createChildren():void {
			View.regComponent("sg.view.com.sgCloseBtn",sgCloseBtn);
			super.createChildren();
			loadUI("com/panel_bg_btn_s");

		}

	}
}