/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;

	public class viewPaySelfUI extends ViewPanel {
		public var btn_ali:Button;
		public var btn_wx:Button;
		public var btn_1:Button;
		public var btn_0:Button;
		public var btnClose:Button;
		public var btnPay:Button;
		public var tNum:Label;
		public var tPrice:Label;
		public var tSalePay:Label;
		public var tTotal:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			super.createChildren();
			loadUI("init/viewPaySelf");

		}

	}
}