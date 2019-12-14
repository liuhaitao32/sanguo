/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.btn_icon_txtUI;
	import ui.com.item_titleUI;

	public class buildingQuicklyUI extends ViewPanel {
		public var mBox:Box;
		public var btn_coin:btn_icon_txtUI;
		public var btn_cd:Button;
		public var btnLess:Button;
		public var btnAdd:Button;
		public var slider:HSlider;
		public var tCdNum:Label;
		public var ttime:Label;
		public var txt_hint0:Label;
		public var txt_hint1:Label;
		public var txt_hint2:Label;
		public var tStatus:Label;
		public var bar_time:ProgressBar;
		public var btn_free:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/buildingQuickly");

		}

	}
}