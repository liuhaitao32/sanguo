/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;
	import ui.com.payTypeBigUI;

	public class viewAlertUI extends ViewPanel {
		public var bg:panel_bg_btn_sUI;
		public var comTitle:item_titleUI;
		public var btn0:Button;
		public var btn1:Button;
		public var contentBox:Box;
		public var text1:Label;
		public var box0:Box;
		public var ttt:Label;
		public var comtype:payTypeBigUI;
		public var text2:Label;
		public var box1:Box;
		public var text3:Label;
		public var btnCheck:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("init/viewAlert");

		}

	}
}