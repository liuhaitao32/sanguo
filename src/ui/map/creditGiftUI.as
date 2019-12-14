/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.map.item_credit_gift_dayUI;
	import ui.map.item_credit_gift_yearUI;
	import ui.com.item_titleUI;

	public class creditGiftUI extends ViewPanel {
		public var dayList:List;
		public var yearList:List;
		public var text1:Label;
		public var text2:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.map.item_credit_gift_dayUI",item_credit_gift_dayUI);
			View.regComponent("ui.map.item_credit_gift_yearUI",item_credit_gift_yearUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/creditGift");

		}

	}
}