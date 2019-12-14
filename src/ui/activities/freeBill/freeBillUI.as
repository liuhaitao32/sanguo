/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.freeBill {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn1UI;
	import ui.com.award_box2UI;

	public class freeBillUI extends ViewPanel {
		public var rewardList:List;
		public var btn_buy:Button;
		public var list:List;
		public var btn_help:Button;
		public var btn_record:Button;
		public var txt_hint2:Label;
		public var timeImg:Image;
		public var timeTxt:Label;
		public var txt_hint1:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn1UI",panel_bg_btn1UI);
			View.regComponent("ui.com.award_box2UI",award_box2UI);
			super.createChildren();
			loadUI("activities/freeBill/freeBill");

		}

	}
}