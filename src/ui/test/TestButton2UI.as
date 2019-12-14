/**Created by the LayaAirIDE,do not modify.*/
package ui.test {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;

	public class TestButton2UI extends ViewPanel {
		public var btn:Button;
		public var label:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			super.createChildren();
			loadUI("test/TestButton2");

		}

	}
}