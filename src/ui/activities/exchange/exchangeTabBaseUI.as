/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.exchange {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class exchangeTabBaseUI extends ComPayType {
		public var rewardBox:Box;
		public var btn:Button;
		public var icon:bagItemUI;
		public var txt_name:Label;
		public var txt_num:Label;
		public var icon_lock:Image;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/exchange/exchangeTabBase");

		}

	}
}