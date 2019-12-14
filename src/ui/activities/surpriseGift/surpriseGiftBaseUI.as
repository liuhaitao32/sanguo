/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.surpriseGift {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import sg.activities.ComIconList;
	import ui.bag.bagItemUI;

	public class surpriseGiftBaseUI extends ItemBase {
		public var btn_buy:Button;
		public var list:ComIconList;
		public var txt_times_hint:Label;
		public var txt_tips:Label;
		public var txt_name:Label;
		public var txt_times:Label;

		override protected function createChildren():void {
			View.regComponent("sg.activities.ComIconList",ComIconList);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/surpriseGift/surpriseGiftBase");

		}

	}
}