/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class server_listUI extends ViewPanel {
		public var listMine:List;
		public var list:List;
		public var zuijin:Label;
		public var fuwu:Label;
		public var zhengchang:Label;
		public var yiyou:Label;
		public var buke:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("init/server_list");

		}

	}
}