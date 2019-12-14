/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.img_c_txt_bUI;
	import ui.activities.rewardItemUI;
	import sg.altar.legend.view.LegendBaseHero;

	public class legendRoadUI extends ViewPanel {
		public var mBox:Box;
		public var comTitle:item_titleUI;
		public var btn_help:Button;
		public var txt_hint:Label;
		public var bar:ProgressBar;
		public var txt_progress:Label;
		public var txt_hint2:Label;
		public var txt_goal:Label;
		public var btn_challenge:Button;
		public var box_limit:Box;
		public var txt_limit:Label;
		public var icon_limit_0:img_c_txt_bUI;
		public var icon_limit_1:img_c_txt_bUI;
		public var reward_list:List;
		public var hero_info:LegendBaseHero;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.img_c_txt_bUI",img_c_txt_bUI);
			View.regComponent("ui.activities.rewardItemUI",rewardItemUI);
			View.regComponent("sg.altar.legend.view.LegendBaseHero",LegendBaseHero);
			super.createChildren();
			loadUI("fight/legendRoad");

		}

	}
}