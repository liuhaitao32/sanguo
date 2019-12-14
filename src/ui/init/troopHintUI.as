/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;
	import ui.com.payTypeSUI;

	public class troopHintUI extends ViewPanel {
		public var bg:panel_bg_btn_sUI;
		public var btn_train:Button;
		public var btn_fill:Button;
		public var txt_content:Label;
		public var com_title:item_titleUI;
		public var txt_info_hint:Label;
		public var box_cost:Box;
		public var txt_cost_hint:Label;
		public var icon_cost:payTypeSUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			super.createChildren();
			loadUI("init/troopHint");

		}

	}
}