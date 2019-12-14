/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.payRank {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.rank_inder_img_t_bigUI;
	import ui.activities.rewardItemUI;

	public class payRankRewardBaseUI extends ItemBase {
		public var comIndex:rank_inder_img_t_bigUI;
		public var txt_name:Label;
		public var txt_hint:Label;
		public var txt_point:Label;
		public var reward_list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.activities.rewardItemUI",rewardItemUI);
			super.createChildren();
			loadUI("activities/payRank/payRankRewardBase");

		}

	}
}