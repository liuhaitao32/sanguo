/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.saleShop {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.btn_icon_double_txtUI;
	import ui.bag.bagItemUI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.payTypeUI;

	public class saleBaseUI extends ComPayType {
		public var rewardBox:Box;
		public var nameTxtPanel:Image;
		public var img_type:Image;
		public var sellOut:Image;
		public var btn_price:btn_icon_double_txtUI;
		public var nameTxt:Label;
		public var rewardItem:bagItemUI;
		public var rebateTxt:Label;
		public var htmlLabel:HTMLDivElement;
		public var hintBox:Box;
		public var hintTxt1:Label;
		public var hintTxt2:Label;
		public var payIcon:payTypeUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.btn_icon_double_txtUI",btn_icon_double_txtUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("activities/saleShop/saleBase");

		}

	}
}