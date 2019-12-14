/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.treasure {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;

	public class treasure_btnUI extends ItemBase {
		public var text0:Label;
		public var comNum:payTypeUI;
		public var text1:Label;
		public var btn:Button;
		public var text2:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("activities/treasure/treasure_btn");

		}

	}
}