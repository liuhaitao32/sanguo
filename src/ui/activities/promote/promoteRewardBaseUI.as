/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.promote {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import sg.activities.view.RewardItem;

	public class promoteRewardBaseUI extends ItemBase {
		public var officialName:Label;
		public var btn_get:Button;
		public var alreadyGet:Image;
		public var rewardIcon:RewardItem;

		override protected function createChildren():void {
			View.regComponent("sg.activities.view.RewardItem",RewardItem);
			super.createChildren();
			loadUI("activities/promote/promoteRewardBase");

		}

	}
}