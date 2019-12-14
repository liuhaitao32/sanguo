/**Created by the LayaAirIDE,do not modify.*/
package ui.explore {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.payTypeUI;
	import ui.com.hero_icon7UI;
	import ui.com.hero_power4UI;

	public class hunt_detailUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var img_name:Image;
		public var btn:Button;
		public var img_pray:Image;
		public var list_enemy:List;
		public var box_mine:Box;
		public var img_resource:Image;
		public var box_hint2:Box;
		public var s0:Image;
		public var s1:Image;
		public var box_battle:Box;
		public var txt_battle:Label;
		public var box_hint0:Box;
		public var txt_income:Label;
		public var box_hint1:Box;
		public var txt_garbed:Label;
		public var list_hero:List;
		public var txt_name:Label;
		public var txt_time:Label;
		public var txt_info:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.com.hero_icon7UI",hero_icon7UI);
			View.regComponent("ui.com.hero_power4UI",hero_power4UI);
			super.createChildren();
			loadUI("explore/hunt_detail");

		}

	}
}