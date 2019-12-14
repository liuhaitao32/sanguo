/**Created by the LayaAirIDE,do not modify.*/
package ui.onlineReward {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.rewardItemUI;

	public class onlineRewardPanelUI extends ViewPanel {
		public var title:Image;
		public var tips:Image;
		public var rewardList:List;
		public var btn_reward:Button;
		public var btn_close:Button;
		public var tipTxt:Label;
		public var payHint:Label;
		public var extraHint:Box;

		override protected function createChildren():void {
			View.regComponent("ui.activities.rewardItemUI",rewardItemUI);
			super.createChildren();
			loadUI("onlineReward/onlineRewardPanel");

		}

	}
}