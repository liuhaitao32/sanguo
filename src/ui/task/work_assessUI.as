/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.hero_icon2UI;
	import ui.com.payTypeBigUI;
	import ui.com.item_titleUI;

	public class work_assessUI extends ViewPanel {
		public var panelBg:panel_bg_btn_sUI;
		public var adImg:Image;
		public var heroIcon:hero_icon2UI;
		public var s0:Image;
		public var s1:Image;
		public var award:payTypeBigUI;
		public var tInfo:Label;
		public var tAdd:Label;
		public var tName:Label;
		public var btn:Button;
		public var list:List;
		public var bar:ProgressBar;
		public var bar2:ProgressBar;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("task/work_assess");

		}

	}
}