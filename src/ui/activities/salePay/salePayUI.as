/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.salePay {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.salePay.salePayItemUI;

	public class salePayUI extends ViewPanel {
		public var list:List;
		public var text1:Label;
		public var text0:Label;
		public var askBtn:Image;

		override protected function createChildren():void {
			View.regComponent("ui.activities.salePay.salePayItemUI",salePayItemUI);
			super.createChildren();
			loadUI("activities/salePay/salePay");

		}

	}
}