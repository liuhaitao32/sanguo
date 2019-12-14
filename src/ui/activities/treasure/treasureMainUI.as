/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.treasure {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.treasure.treasure_btnUI;
	import ui.activities.treasure.item_treasureUI;
	import ui.activities.dial.item_dialUI;

	public class treasureMainUI extends ItemBase {
		public var tempImg:Image;
		public var comCenter0:treasure_btnUI;
		public var comCenter1:treasure_btnUI;
		public var com0:item_treasureUI;
		public var com1:item_treasureUI;
		public var com2:item_treasureUI;
		public var com3:item_treasureUI;
		public var com4:item_treasureUI;
		public var com5:item_treasureUI;
		public var com6:item_treasureUI;
		public var com7:item_treasureUI;
		public var list:List;
		public var timeImg:Image;
		public var text0:Label;
		public var timerLabel:Label;
		public var numLabel:Label;
		public var btnShop:Button;
		public var btnAsk:Button;

		override protected function createChildren():void {
			View.regComponent("ui.activities.treasure.treasure_btnUI",treasure_btnUI);
			View.regComponent("ui.activities.treasure.item_treasureUI",item_treasureUI);
			View.regComponent("ui.activities.dial.item_dialUI",item_dialUI);
			super.createChildren();
			loadUI("activities/treasure/treasureMain");

		}

	}
}