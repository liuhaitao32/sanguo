/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.payRank {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.rank_inder_img_t_bigUI;

	public class payRankBaseUI extends ItemBase {
		public var img_bg:Image;
		public var icon_hero:hero_icon1UI;
		public var comIndex:rank_inder_img_t_bigUI;
		public var txt_name:Label;
		public var txt_hint:Label;
		public var txt_point:Label;
		public var img_reward:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			super.createChildren();
			loadUI("activities/payRank/payRankBase");

		}

	}
}