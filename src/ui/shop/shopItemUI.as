/**Created by the LayaAirIDE,do not modify.*/
package ui.shop {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.btn_icon_txt_sureUI;

	public class shopItemUI extends ItemBase {
		public var box:Box;
		public var com:bagItemUI;
		public var goodBG:Image;
		public var rarityIcon:Image;
		public var goodName:Label;
		public var btnBuy:btn_icon_txt_sureUI;
		public var costIcon:Image;
		public var costText:Label;
		public var costLabel:Label;
		public var lockLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("shop/shopItem");

		}

	}
}