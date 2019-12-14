/**Created by the LayaAirIDE,do not modify.*/
package ui {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;

	public class ViewTestFightUI extends ViewPanel {
		public var tStatus:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			super.createChildren();
			loadUI("ViewTestFight");

		}

	}
}