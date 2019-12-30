/**Created by the LayaAirIDE,do not modify.*/
package ui.activities {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.hero_icon2UI;
	import ui.com.btn_icon_double_txtUI;

	public class payAgainUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var img_bg:Image;
		public var comHero:hero_icon2UI;
		public var tabList:List;
		public var box_reward:Box;
		public var txt_time:Label;
		public var txt_tips:Label;
		public var btn_price:btn_icon_double_txtUI;
		public var txt_tips2:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.btn_icon_double_txtUI",btn_icon_double_txtUI);
			super.createChildren();
			loadUI("activities/payAgain");

		}

	}
}