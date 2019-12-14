/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.payRank {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class payRankTipsUI extends ViewPanel {
		public var box_zero:Box;
		public var img_ad_zero:Image;
		public var box_one:Box;
		public var img_ad_one:Image;
		public var box1:Panel;
		public var heroIcon1:hero_icon2UI;
		public var heroName1:Label;
		public var box_two:Box;
		public var img_ad_two:Image;
		public var box2_1:Panel;
		public var heroIcon2_1:hero_icon2UI;
		public var box2_2:Panel;
		public var heroIcon2_2:hero_icon2UI;
		public var heroName2_1:Label;
		public var heroName2_2:Label;
		public var box_tips:Box;
		public var txt_tips:Label;
		public var box_go:Box;
		public var txt_go:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("activities/payRank/payRankTips");

		}

	}
}