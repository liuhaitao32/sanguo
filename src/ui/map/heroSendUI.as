/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.payTypeSUI;
	import ui.com.hero_power2UI;
	import ui.com.item_titleUI;

	public class heroSendUI extends ViewPanel {
		public var boxMain:Box;
		public var btn_send:Button;
		public var tStatus:Label;
		public var tPowerInfo:Label;
		public var box_other:Box;
		public var text1:Label;
		public var text0:Label;
		public var boxPay:Box;
		public var text2:Label;
		public var tPayTime:payTypeSUI;
		public var tPayFood:payTypeSUI;
		public var comPower:hero_power2UI;
		public var cTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/heroSend");

		}

	}
}