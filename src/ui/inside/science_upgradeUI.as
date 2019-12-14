/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.btn_icon_txtUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.item_science_iconUI;
	import ui.com.item_titleUI;

	public class science_upgradeUI extends ViewPanel {
		public var mBox:Box;
		public var btn_coin:btn_icon_txtUI;
		public var btn_cd:btn_icon_txt_sureUI;
		public var priceRuler:Label;
		public var tName:Label;
		public var tLv:Label;
		public var tInfo:Label;
		public var tStatus:Label;
		public var mingcheng:Label;
		public var dengji:Label;
		public var tStatus2:Label;
		public var icon:item_science_iconUI;
		public var mQuick:Box;
		public var tQuick:Label;
		public var btn_quick:Button;
		public var iconUp:item_science_iconUI;
		public var tTips:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.item_science_iconUI",item_science_iconUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/science_upgrade");

		}

	}
}