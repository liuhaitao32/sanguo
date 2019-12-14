/**Created by the LayaAirIDE,do not modify.*/
package ui.explore {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.hero_icon2UI;
	import ui.com.payTypeUI;

	public class pray_panelUI extends ViewPanel {
		public var box:Box;
		public var comTitle:item_titleUI;
		public var img_bg:Image;
		public var img_hero:hero_icon2UI;
		public var img_ptayTool:Image;
		public var txt_words:Label;
		public var btn_pray:Button;
		public var box_result:Box;
		public var s0:Image;
		public var s1:Image;
		public var txt_name:Label;
		public var txt_info:Label;
		public var txt_tip:Label;
		public var txt_hint:Label;
		public var box_tool:Box;
		public var iconTool:payTypeUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("explore/pray_panel");

		}

	}
}