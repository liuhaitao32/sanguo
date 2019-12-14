/**Created by the LayaAirIDE,do not modify.*/
package ui.activities {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.rewardItemUI;

	public class payMentUI extends ViewPanel {
		public var pic1:Image;
		public var btn_close:Button;
		public var pic2:Image;
		public var pic3:Image;
		public var btn_pay:Button;
		public var pic4:Image;
		public var rewardList:List;
		public var previewTxt:Label;
		public var needMoney:Label;

		override protected function createChildren():void {
			View.regComponent("ui.activities.rewardItemUI",rewardItemUI);
			super.createChildren();
			loadUI("activities/payMent");

		}

	}
}