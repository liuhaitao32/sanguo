/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.dial {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.treasure.item_treasureUI;
	import ui.com.payTypeUI;
	import ui.activities.dial.item_dialUI;

	public class dialMainUI extends ItemBase {
		public var tempImg:Image;
		public var timeBox:Box;
		public var timeImg:Image;
		public var text0:Label;
		public var timerLabel:Label;
		public var boxLeft:Box;
		public var text2Img:Image;
		public var text2:Label;
		public var numLabel1:Label;
		public var boxRight:Box;
		public var text3Img:Image;
		public var text3:Label;
		public var numLabel2:Label;
		public var bgBox:Box;
		public var imgArrow:Image;
		public var btnChoose:Button;
		public var btnGet:Button;
		public var btnChange:Button;
		public var com0:item_treasureUI;
		public var com1:item_treasureUI;
		public var com2:item_treasureUI;
		public var com3:item_treasureUI;
		public var com4:item_treasureUI;
		public var com5:item_treasureUI;
		public var com6:item_treasureUI;
		public var com7:item_treasureUI;
		public var com8:item_treasureUI;
		public var com9:item_treasureUI;
		public var boxCom:Box;
		public var comImg:Image;
		public var comNum:payTypeUI;
		public var text1:Label;
		public var box2:Box;
		public var text4:Label;
		public var box1:Box;
		public var boxTips:Box;
		public var buyNum:Label;
		public var btnRecord:Button;
		public var btnAsk:Button;
		public var list:List;
		public var btnPay:Button;

		override protected function createChildren():void {
			View.regComponent("ui.activities.treasure.item_treasureUI",item_treasureUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.activities.dial.item_dialUI",item_dialUI);
			super.createChildren();
			loadUI("activities/dial/dialMain");

		}

	}
}