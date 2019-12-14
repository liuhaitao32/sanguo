/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.item_titleUI;

	public class equipWashGFUI extends ViewPanel {
		public var btnGiveUp:Button;
		public var btnSave:Button;
		public var btnWash:btn_icon_txt_sureUI;
		public var text3:Label;
		public var text4:Label;
		public var text5:Label;
		public var text2:Label;
		public var text1:Label;
		public var comTitle:item_titleUI;
		public var numBox:Box;
		public var imgNum:Image;
		public var numLabel:Label;
		public var text6:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/equipWashGF");

		}

	}
}