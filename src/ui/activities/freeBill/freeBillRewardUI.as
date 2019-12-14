/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.freeBill {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class freeBillRewardUI extends ViewPanel {
		public var box:Box;
		public var img0:Image;
		public var img1:Image;
		public var img2:Image;
		public var closehint:Label;
		public var txt_tips:Label;
		public var reward:bagItemUI;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/freeBill/freeBillReward");

		}

	}
}