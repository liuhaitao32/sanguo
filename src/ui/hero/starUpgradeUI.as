/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.SoldiersinformationUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.btn_icon_txtUI;
	import ui.com.hero_starUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class starUpgradeUI extends ViewPanel {
		public var btnGoto:Button;
		public var boxPropF:SoldiersinformationUI;
		public var btn_gold:btn_icon_txt_sureUI;
		public var btn_coin:btn_icon_txtUI;
		public var boxPropB:SoldiersinformationUI;
		public var barStar:ProgressBar;
		public var btn_go:Button;
		public var tRight:Label;
		public var tStarPro:Label;
		public var heroStar:hero_starUI;
		public var mItem:bagItemUI;
		public var gTxt:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.SoldiersinformationUI",SoldiersinformationUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("hero/starUpgrade");

		}

	}
}