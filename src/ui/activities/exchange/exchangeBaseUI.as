/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.exchange {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.btn_icon_txt_sureUI;
	import laya.html.dom.HTMLDivElement;

	public class exchangeBaseUI extends ComPayType {
		public var rewardBox:Box;
		public var img_type:Image;
		public var rewardItem:bagItemUI;
		public var btn_price:btn_icon_txt_sureUI;
		public var sellOut:Image;
		public var nameTxt:Label;
		public var box_own:Box;
		public var text0:Label;
		public var box_limit:Box;
		public var htmlLabel:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("activities/exchange/exchangeBase");

		}

	}
}