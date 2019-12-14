/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class heroProNormalItemUI extends ViewPanel {
		public var setMust:Button;
		public var btn_ok:Button;
		public var btn_no:Button;
		public var tPay:Label;
		public var tHave:Label;
		public var tPayNum:Label;
		public var tHaveNum:Label;
		public var tMust:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("hero/heroProNormalItem");

		}

	}
}