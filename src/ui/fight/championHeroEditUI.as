/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.hero_icon2UI;
	import ui.com.hero_power1UI;
	import ui.com.item_titleUI;

	public class championHeroEditUI extends ViewPanel {
		public var adImg:Image;
		public var heroIcon:hero_icon2UI;
		public var comPower:hero_power1UI;
		public var tName:Label;
		public var list:List;
		public var text0:Label;
		public var btn:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_power1UI",hero_power1UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("fight/championHeroEdit");

		}

	}
}