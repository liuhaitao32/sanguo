/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.hero_icon2UI;
	import ui.com.award_box4UI;

	public class honourFinishUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var text0:Label;
		public var text1:Label;
		public var text2:Label;
		public var text3:Label;
		public var text4:Label;
		public var btn:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.award_box4UI",award_box4UI);
			super.createChildren();
			loadUI("honour/honourFinish");

		}

	}
}