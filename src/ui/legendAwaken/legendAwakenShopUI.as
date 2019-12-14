/**Created by the LayaAirIDE,do not modify.*/
package ui.legendAwaken {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.hero_icon2UI;
	import ui.com.payTypeBigUI;
	import ui.com.item_talentUI;
	import ui.com.item_awakenUI;
	import ui.legendAwaken.legendAwakenListBaseUI;
	import ui.com.btn_icon_txt_sureUI;

	public class legendAwakenShopUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var mFuncImg:Box;
		public var imgSuper:Image;
		public var heroIconBg:Image;
		public var imgAwaken:Image;
		public var heroIcon:hero_icon2UI;
		public var btn_draw:Button;
		public var txt_time:Label;
		public var txt_item:Label;
		public var itemIcon:payTypeBigUI;
		public var txt_hero:Label;
		public var comTalent:item_talentUI;
		public var imgRarity:Image;
		public var comAwaken:item_awakenUI;
		public var list:List;
		public var btn_help:Button;
		public var btn_price:btn_icon_txt_sureUI;
		public var box_hint:Box;
		public var btn_pay:Button;
		public var txt_pay_hint:Label;
		public var payIcon_hint:payTypeBigUI;
		public var btn_awaken:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			View.regComponent("ui.com.item_talentUI",item_talentUI);
			View.regComponent("ui.com.item_awakenUI",item_awakenUI);
			View.regComponent("ui.legendAwaken.legendAwakenListBaseUI",legendAwakenListBaseUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("legendAwaken/legendAwakenShop");

		}

	}
}