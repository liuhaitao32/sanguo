/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.hero_icon1UI;
	import ui.com.item_titleUI;

	public class lvUpgradeUI extends ViewPanel {
		public var mBox:Box;
		public var barExp:ProgressBar;
		public var tLv:Label;
		public var tExp:Label;
		public var txt_hint:Label;
		public var heroIcon:hero_icon1UI;
		public var clipBox:Box;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("hero/lvUpgrade");

		}

	}
}