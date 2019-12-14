/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.saleShop {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeBigUI;

	public class saleShopUI extends ItemBase {
		public var timeImg:Image;
		public var list:List;
		public var btn_pay:Button;
		public var payIcon:payTypeBigUI;
		public var timeTxt:Label;
		public var hintTxt:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("activities/saleShop/saleShop");

		}

	}
}