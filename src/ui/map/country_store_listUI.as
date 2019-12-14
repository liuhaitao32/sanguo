/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;

	public class country_store_listUI extends ViewPanel {
		public var btn:Button;
		public var tTimes:Label;
		public var iNum:Label;
		public var tNum:Label;
		public var list:List;
		public var txt_title:Label;
		public var tab:Tab;
		public var list_title:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			super.createChildren();
			loadUI("map/country_store_list");

		}

	}
}