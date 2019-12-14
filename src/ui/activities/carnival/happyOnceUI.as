/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class happyOnceUI extends ItemBase {
		public var pro0:Box;
		public var pro1:Box;
		public var pro2:Box;
		public var pro3:Box;
		public var pro4:Box;
		public var list:List;
		public var btn:Button;
		public var rewardLabel0:Label;
		public var rewardLabel1:Label;
		public var numLabel:Label;
		public var com0:bagItemUI;
		public var com1:bagItemUI;
		public var timeBox:Box;
		public var timerImg:Image;
		public var text0:Label;
		public var timerLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/carnival/happyOnce");

		}

	}
}