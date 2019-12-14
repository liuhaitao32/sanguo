/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.building_info_infoUI;
	import ui.com.btn_icon_txtUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.item_titleUI;

	public class armyMakeUI extends ViewPanel {
		public var mBox:Box;
		public var img:Image;
		public var infoBox:building_info_infoUI;
		public var tPay:Label;
		public var btn_coin:btn_icon_txtUI;
		public var btn_cd:btn_icon_txt_sureUI;
		public var btnLess:Button;
		public var btnAdd:Button;
		public var slider:HSlider;
		public var tNum:Label;
		public var btn_max:Button;
		public var txt_hint_choose:Label;
		public var armyNum:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.building_info_infoUI",building_info_infoUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/armyMake");

		}

	}
}