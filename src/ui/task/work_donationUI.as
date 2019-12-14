/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.payTypeBigUI;
	import ui.com.hero_icon2UI;
	import ui.com.item_titleUI;

	public class work_donationUI extends ViewPanel {
		public var adImg:Image;
		public var tTalk:Label;
		public var award:payTypeBigUI;
		public var btn:Button;
		public var btn_less:Button;
		public var btn_add:Button;
		public var tAdd:Label;
		public var tInfo:Label;
		public var tNum:Label;
		public var iLess:Label;
		public var tLess:Label;
		public var heroIcon:hero_icon2UI;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("task/work_donation");

		}

	}
}