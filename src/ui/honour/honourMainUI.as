/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.award_box4UI;
	import ui.honour.heroHonourUI;

	public class honourMainUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var tTime:Label;
		public var text0:Label;
		public var tLv:Label;
		public var tRank:Label;
		public var btnRank:Button;
		public var btnHistory:Button;
		public var btnChallenge:Button;
		public var tTips:Label;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.award_box4UI",award_box4UI);
			View.regComponent("ui.honour.heroHonourUI",heroHonourUI);
			super.createChildren();
			loadUI("honour/honourMain");

		}

	}
}