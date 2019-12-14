/**Created by the LayaAirIDE,do not modify.*/
package ui.shop {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class shopItemTipsUI extends ViewPanel {
		public var box:Box;
		public var icon:bagItemUI;
		public var nameLabel:Label;
		public var numLabel:Label;
		public var infoLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("shop/shopItemTips");

		}

	}
}