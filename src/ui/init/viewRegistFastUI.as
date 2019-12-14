/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;

	public class viewRegistFastUI extends ViewPanel {
		public var t1:Label;
		public var t2:Label;
		public var comTitle:item_titleUI;
		public var tName:Label;
		public var tPass:Label;
		public var tInfo:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("init/viewRegistFast");

		}

	}
}