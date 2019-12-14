/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.btn_icon_txtUI;
	import ui.map.itemHeroEstateUI;
	import ui.com.item_titleUI;

	public class estateHeroUI extends ViewPanel {
		public var okBtn:btn_icon_txtUI;
		public var infoLabel:Label;
		public var timerLabel:Label;
		public var list:List;
		public var getBtn:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.map.itemHeroEstateUI",itemHeroEstateUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/estateHero");

		}

	}
}