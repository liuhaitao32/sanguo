/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.hero_icon1UI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.item_titleUI;
	import ui.com.hero_power2UI;

	public class estateHeroInfoUI extends ViewPanel {
		public var imgType:Image;
		public var infoLabel:Label;
		public var nameLabel:Label;
		public var text0:Label;
		public var lvLabel:Label;
		public var timeLabel:Label;
		public var timePro:ProgressBar;
		public var comHero:hero_icon1UI;
		public var btn:btn_icon_txt_sureUI;
		public var comTitle:item_titleUI;
		public var comPower:hero_power2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("map/estateHeroInfo");

		}

	}
}