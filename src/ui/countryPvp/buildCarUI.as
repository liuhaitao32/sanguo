/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.payTypeUI;

	public class buildCarUI extends ViewPanel {
		public var allBox:Box;
		public var cTitle:item_titleUI;
		public var imgBig:Image;
		public var infoBox:Box;
		public var list:List;
		public var btnAsk:Button;
		public var tName:Label;
		public var proBox:Box;
		public var pPro:ProgressBar;
		public var tPro:Label;
		public var timeBox1:Box;
		public var tTime1:Label;
		public var hamBox:Box;
		public var tAir:Label;
		public var cCost0:payTypeUI;
		public var cCost2:payTypeUI;
		public var cCost1:payTypeUI;
		public var btn0:Button;
		public var btn1:Button;
		public var text0:Label;
		public var carPanel:Panel;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("countryPvp/buildCar");

		}

	}
}