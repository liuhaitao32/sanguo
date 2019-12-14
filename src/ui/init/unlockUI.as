/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.payTypeSUI;
	import ui.com.item_titleUI;

	public class unlockUI extends ViewPanel {
		public var pay:payTypeSUI;
		public var tInfo:Label;
		public var btn:Button;
		public var text0:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("init/unlock");

		}

	}
}