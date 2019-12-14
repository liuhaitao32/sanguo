/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.payRank {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;

	public class payRankRewardUI extends ViewPanel {
		public var com_title:item_titleUI;
		public var tab:Tab;
		public var box_hint:Box;
		public var txt_none:Label;
		public var list:List;
		public var txt_hint:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("activities/payRank/payRankReward");

		}

	}
}