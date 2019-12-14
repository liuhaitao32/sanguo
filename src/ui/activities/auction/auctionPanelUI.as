/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.auction {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn1UI;
	import ui.com.item_title1UI;
	import ui.activities.auction.auctionBaseUI;

	public class auctionPanelUI extends ViewPanel {
		public var mBox:Box;
		public var comTitle:item_title1UI;
		public var btn_help:Button;
		public var list:List;
		public var txt_hint:Label;
		public var box_hero:Box;
		public var list_hero:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn1UI",panel_bg_btn1UI);
			View.regComponent("ui.com.item_title1UI",item_title1UI);
			View.regComponent("ui.activities.auction.auctionBaseUI",auctionBaseUI);
			super.createChildren();
			loadUI("activities/auction/auctionPanel");

		}

	}
}