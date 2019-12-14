/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.hero_icon2UI;
	import ui.com.hero_power1UI;
	import ui.com.payTypeBigUI;
	import ui.com.item_titleUI;

	public class championBetEditUI extends ViewPanel {
		public var adImg:Image;
		public var heroIcon:hero_icon2UI;
		public var text0:Label;
		public var mBet:Box;
		public var bar:HSlider;
		public var tNum:Label;
		public var text2:Label;
		public var comPower:hero_power1UI;
		public var cost:payTypeBigUI;
		public var btn:Button;
		public var tName:Label;
		public var text1:Label;
		public var tBet:Label;
		public var tMyBet:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_power1UI",hero_power1UI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("fight/championBetEdit");

		}

	}
}