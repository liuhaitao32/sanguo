/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.exchange {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class exchangeShopUI extends ItemBase {
		public var timeImg:Image;
		public var timeTxt:Label;
		public var hintTxt:Label;
		public var list:List;
		public var list_tab:List;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("activities/exchange/exchangeShop");

		}

	}
}