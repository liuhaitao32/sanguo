/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.treasure {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn1UI;
	import ui.activities.saleShop.saleBaseUI;
	import ui.com.item_title1UI;
	import ui.com.payTypeUI;

	public class treasureShopUI extends ViewPanel {
		public var list:List;
		public var comTitle:item_title1UI;
		public var box0:Box;
		public var numLabel:Label;
		public var box1:Box;
		public var cCom:payTypeUI;
		public var tItemName:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn1UI",panel_bg_btn1UI);
			View.regComponent("ui.activities.saleShop.saleBaseUI",saleBaseUI);
			View.regComponent("ui.com.item_title1UI",item_title1UI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("activities/treasure/treasureShop");

		}

	}
}