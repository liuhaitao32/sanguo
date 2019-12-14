/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.bag.bagItemUI;
	import ui.com.payTypeUI;
	import ui.com.hero_power2UI;
	import ui.com.item_titleUI;

	public class estateDetailsUI extends ViewPanel {
		public var all:Box;
		public var imgIcon:Image;
		public var com0:bagItemUI;
		public var btn1:Button;
		public var btn0:Button;
		public var numLabel:Label;
		public var text0:Label;
		public var text4:Label;
		public var text3:Label;
		public var text5:Label;
		public var box1:Box;
		public var imgText:Image;
		public var timesLabel:Label;
		public var activeLabel:Label;
		public var box2:Box;
		public var iconLabel:Label;
		public var com1:payTypeUI;
		public var centerLabel:Label;
		public var boxPower:Box;
		public var tPowerName:Label;
		public var comPower:hero_power2UI;
		public var comTitle:item_titleUI;
		public var comCoin:bagItemUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/estateDetails");

		}

	}
}