/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.inside.equipItemUI;
	import ui.com.hero_icon_equipUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.btn_icon_txt_blueUI;
	import ui.com.item_titleUI;

	public class equipUpgradeUI extends ViewPanel {
		public var tab:Tab;
		public var adImg:Image;
		public var list:List;
		public var mInfo:Box;
		public var mItem:hero_icon_equipUI;
		public var priceBg:Image;
		public var btn_cd:btn_icon_txt_sureUI;
		public var btn_coin:btn_icon_txt_blueUI;
		public var priceRuler:Label;
		public var tHero:Label;
		public var tName:Label;
		public var tInfo:Label;
		public var mBoxInfo:Box;
		public var text0:Label;
		public var tEquipInfo:Label;
		public var mBoxPro:Image;
		public var btn_change:Button;
		public var tReady2:Label;
		public var tList:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.inside.equipItemUI",equipItemUI);
			View.regComponent("ui.com.hero_icon_equipUI",hero_icon_equipUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.btn_icon_txt_blueUI",btn_icon_txt_blueUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/equipUpgrade");

		}

	}
}