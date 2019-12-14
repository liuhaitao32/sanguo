/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.auction {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;
	import ui.com.payTypeBigUI;

	public class auctionBidUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var btn_bid:Button;
		public var slider:HSlider;
		public var btn_sub:Button;
		public var btn_add:Button;
		public var txt_gift_name:Label;
		public var txt_hint1:Label;
		public var txt_hint2:Label;
		public var icon_cost0:payTypeBigUI;
		public var icon_cost1:payTypeBigUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("activities/auction/auctionBid");

		}

	}
}