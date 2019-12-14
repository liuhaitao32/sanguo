/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.wish {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.award_box1UI;
	import ui.activities.rewardItemUI;

	public class wish_mainUI extends ItemBase {
		public var character:Image;
		public var title:Image;
		public var logintips:Image;
		public var tipsImg:Image;
		public var comBox:award_box1UI;
		public var btn_reward:Button;
		public var refreshTips:Label;
		public var wishTips:Label;
		public var payHint:Label;
		public var wishHintWords:Label;
		public var rewardList:List;
		public var daysBox:Box;
		public var dayImg:Image;
		public var daysTxt:Label;
		public var daysHint:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.award_box1UI",award_box1UI);
			View.regComponent("ui.activities.rewardItemUI",rewardItemUI);
			super.createChildren();
			loadUI("activities/wish/wish_main");

		}

	}
}