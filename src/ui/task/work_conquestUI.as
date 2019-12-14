/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.hero_icon2UI;
	import ui.com.hero_power2UI;
	import ui.com.item_titleUI;

	public class work_conquestUI extends ViewPanel {
		public var boxMain:Box;
		public var adImg:Image;
		public var heroIcon:hero_icon2UI;
		public var btn_sendTroop:Button;
		public var tInfo:Label;
		public var tFoeLv:Label;
		public var tLvName:Label;
		public var tPowerName:Label;
		public var tName:Label;
		public var tTips:Label;
		public var comPower:hero_power2UI;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("task/work_conquest");

		}

	}
}