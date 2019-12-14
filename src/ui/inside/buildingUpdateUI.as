/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.btn_icon_txtUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.building_info_lvUI;
	import ui.com.building_info_infoUI;
	import ui.com.item_titleUI;

	public class buildingUpdateUI extends ViewPanel {
		public var mBox:Box;
		public var line:Image;
		public var tbuilder_ok:Label;
		public var tPay:Label;
		public var list_if:List;
		public var box_update:Box;
		public var btn_coin:btn_icon_txtUI;
		public var btn_cd:btn_icon_txt_sureUI;
		public var bBox:building_info_lvUI;
		public var bBoxInfo:building_info_infoUI;
		public var btn_free:Button;
		public var bInfo:Box;
		public var txt_title1:Label;
		public var tBinfo:Label;
		public var btnInfo:Button;
		public var tMax:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.building_info_lvUI",building_info_lvUI);
			View.regComponent("ui.com.building_info_infoUI",building_info_infoUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/buildingUpdate");

		}

	}
}