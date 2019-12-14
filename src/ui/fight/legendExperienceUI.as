/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn1UI;
	import ui.com.item_title1UI;
	import ui.com.item_title_s2UI;
	import ui.bag.bagItemUI;
	import ui.activities.rewardItemUI;
	import sg.altar.legend.view.LegendBaseHero;
	import ui.com.img_c_txt_bUI;

	public class legendExperienceUI extends ViewPanel {
		public var mBox:Box;
		public var comTitle:item_title1UI;
		public var btn_help:Button;
		public var btn_challenge:Button;
		public var comHint2:item_title_s2UI;
		public var icon_reward:bagItemUI;
		public var reward_list:List;
		public var txt_tips:Label;
		public var img_hint:Image;
		public var hero_info:LegendBaseHero;
		public var box_limit:Box;
		public var txt_limit:Label;
		public var icon_limit_0:img_c_txt_bUI;
		public var icon_limit_1:img_c_txt_bUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn1UI",panel_bg_btn1UI);
			View.regComponent("ui.com.item_title1UI",item_title1UI);
			View.regComponent("ui.com.item_title_s2UI",item_title_s2UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.activities.rewardItemUI",rewardItemUI);
			View.regComponent("sg.altar.legend.view.LegendBaseHero",LegendBaseHero);
			View.regComponent("ui.com.img_c_txt_bUI",img_c_txt_bUI);
			super.createChildren();
			loadUI("fight/legendExperience");

		}

	}
}