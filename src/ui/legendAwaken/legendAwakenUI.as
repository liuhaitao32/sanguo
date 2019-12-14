/**Created by the LayaAirIDE,do not modify.*/
package ui.legendAwaken {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.payTypeBigUI;
	import ui.com.btn_icon_txt_sureUI;
	import sg.altar.legendAwaken.view.HeroRollBox;

	public class legendAwakenUI extends ViewPanel {
		public var box:Box;
		public var comTitle:item_titleUI;
		public var txt_time:Label;
		public var txt_item:Label;
		public var itemIcon:payTypeBigUI;
		public var btn_help:Button;
		public var btn_drop:Button;
		public var btn_shop:Button;
		public var txt_tips:Label;
		public var box_buy0:Box;
		public var btn_buy_0:btn_icon_txt_sureUI;
		public var txt_buy_tips0_0:Label;
		public var txt_buy_tips0_1:Label;
		public var payIcon_0:payTypeBigUI;
		public var box_buy1:Box;
		public var btn_buy_1:btn_icon_txt_sureUI;
		public var txt_buy_tips1_1:Label;
		public var txt_buy_tips1_0:Label;
		public var payIcon_1:payTypeBigUI;
		public var box_heroRoll:HeroRollBox;
		public var comBoxBg:Image;
		public var comBox:Box;
		public var box_hint:Box;
		public var btn_pay:Button;
		public var txt_hint_0:Label;
		public var payIcon_hint:payTypeBigUI;
		public var mBtn:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("sg.altar.legendAwaken.view.HeroRollBox",HeroRollBox);
			super.createChildren();
			loadUI("legendAwaken/legendAwaken");

		}

	}
}