/**Created by the LayaAirIDE,do not modify.*/
package ui.shop {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class shopEquipTipsUI extends ViewPanel {
		public var box:Box;
		public var icon:bagItemUI;
		public var nameLabel:Label;
		public var numLabel:Label;
		public var infoLabel:Label;
		public var eBox:Box;
		public var equipIcon:bagItemUI;
		public var eNameLabel:Label;
		public var eInfoLabel:Label;
		public var text0:Label;
		public var tType:Label;
		public var imgBG:Image;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("shop/shopEquipTips");

		}

	}
}