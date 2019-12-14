/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.payChoose {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class payChooseBaseUI extends ComPayType {
		public var rewardBox:Box;
		public var rewardItem:bagItemUI;
		public var checkBox:Button;
		public var img_border:Image;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/payChoose/payChooseBase");

		}

	}
}