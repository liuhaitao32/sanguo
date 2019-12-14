/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.estate_btn_labelUI;
	import ui.com.item_titleUI;

	public class estateCheckUI extends ViewPanel {
		public var list1:List;
		public var text0:Label;
		public var text1:Label;
		public var list2:List;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.estate_btn_labelUI",estate_btn_labelUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/estateCheck");

		}

	}
}