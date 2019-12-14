/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class festival_exchange_baseUI extends ComPayType {
		public var rewardBox:Box;
		public var nameTxtPanel:Image;
		public var sellOut:Image;
		public var img_num_panel:Image;
		public var txt_hint2:Label;
		public var rewardItem:bagItemUI;
		public var btn_get:Button;
		public var txt_hint1:Label;
		public var txt_num:Label;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("festival/festival_exchange_base");

		}

	}
}