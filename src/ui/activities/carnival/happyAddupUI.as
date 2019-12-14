/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeBigUI;
	import ui.activities.carnival.item_addupUI;

	public class happyAddupUI extends ItemBase {
		public var btnCheck:Button;
		public var numCom:payTypeBigUI;
		public var list:List;
		public var timeBox:Box;
		public var timerImg:Image;
		public var text0:Label;
		public var timerLabel:Label;
		public var doubleBox:Box;
		public var tText:Label;
		public var tTime:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			View.regComponent("ui.activities.carnival.item_addupUI",item_addupUI);
			super.createChildren();
			loadUI("activities/carnival/happyAddup");

		}

	}
}