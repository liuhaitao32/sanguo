/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.payChoose {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;

	public class payChooseShopUI extends ItemBase {
		public var timeImg:Image;
		public var btn:Button;
		public var timeTxt:Label;
		public var hintTxt:Label;
		public var list:List;
		public var txt_needHint:Label;
		public var txt_tips:Label;
		public var box1:Box;
		public var img1:Image;
		public var txt_alreadyPayHint:Label;
		public var payIcon:payTypeUI;
		public var box2:Box;
		public var img2:Image;
		public var txt_getTimes:Label;
		public var txt_canGetHint:Label;
		public var box3:Box;
		public var img3:Image;
		public var txt_remainTimes:Label;
		public var txt_remainTimesHint:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("activities/payChoose/payChooseShop");

		}

	}
}