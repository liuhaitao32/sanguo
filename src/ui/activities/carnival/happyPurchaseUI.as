/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.btn_icon_double_txtUI;

	public class happyPurchaseUI extends ItemBase {
		public var numLabel:Label;
		public var rewardList:List;
		public var infoLabel:Label;
		public var payLabel:Label;
		public var timeBox:Box;
		public var timerImg:Image;
		public var text0:Label;
		public var timerLabel:Label;
		public var btn:btn_icon_double_txtUI;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.btn_icon_double_txtUI",btn_icon_double_txtUI);
			super.createChildren();
			loadUI("activities/carnival/happyPurchase");

		}

	}
}