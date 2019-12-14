/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.carnival.item_happyUI;

	public class happyLoginUI extends ItemBase {
		public var list:List;
		public var timeBox:Box;
		public var timerImg:Image;
		public var text0:Label;
		public var timerLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.activities.carnival.item_happyUI",item_happyUI);
			super.createChildren();
			loadUI("activities/carnival/happyLogin");

		}

	}
}