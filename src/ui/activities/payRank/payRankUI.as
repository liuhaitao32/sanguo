/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.payRank {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.award_box5UI;
	import ui.com.hero_icon2UI;

	public class payRankUI extends ViewScenes {
		public var box_zero:Box;
		public var box_one:Box;
		public var box_two:Box;
		public var box_hint:Box;
		public var txt_none:Label;
		public var list_hero:List;
		public var txt_rank_hint:Label;
		public var txt_rank:Label;
		public var txt_title_rank:Label;
		public var txt_points_hint:Label;
		public var txt_points:Label;
		public var list_reward:List;
		public var btn_help:Button;
		public var timeBox:Box;
		public var time_end_panel:Image;
		public var txt_time_end_hint:Label;
		public var txt_time_end:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.award_box5UI",award_box5UI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("activities/payRank/payRank");

		}

	}
}