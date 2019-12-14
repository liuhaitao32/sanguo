/**Created by the LayaAirIDE,do not modify.*/
package ui.shop {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.shop.shop_icon_textUI;
	import ui.shop.shopItemUI;
	import ui.com.payTypeUI;
	import ui.com.btn_icon_txtUI;

	public class shopMainUI extends ViewScenes {
		public var box:Box;
		public var barList:List;
		public var arrow_r:Box;
		public var arrow_l:Box;
		public var allBox:Box;
		public var itemList:List;
		public var text1:Label;
		public var costCom:Box;
		public var comNum:payTypeUI;
		public var btnAdd:Button;
		public var refreshCom:Box;
		public var text2:Label;
		public var timerText:Label;
		public var btnRefresh:btn_icon_txtUI;

		override protected function createChildren():void {
			View.regComponent("ui.shop.shop_icon_textUI",shop_icon_textUI);
			View.regComponent("ui.shop.shopItemUI",shopItemUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			super.createChildren();
			loadUI("shop/shopMain");

		}

	}
}