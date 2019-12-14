/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.salePay {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.salePay.salePayItemUI;
	import ui.com.hero_icon2UI;

	public class salePayAlertUI extends ViewPanel {
		public var tempImg:Image;
		public var list:List;
		public var text1:Label;
		public var text0:Label;
		public var heroIcon:hero_icon2UI;
		public var btn:Button;

		override protected function createChildren():void {
			View.regComponent("ui.activities.salePay.salePayItemUI",salePayItemUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("activities/salePay/salePayAlert");

		}

	}
}