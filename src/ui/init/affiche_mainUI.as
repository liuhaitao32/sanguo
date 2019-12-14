/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class affiche_mainUI extends ViewPanel {
		public var btn_close:Button;
		public var tabList:List;
		public var txt_date:Label;
		public var container_img:Box;
		public var container_title:Box;
		public var title:Label;
		public var container_info:Panel;
		public var com_title:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("init/affiche_main");

		}

	}
}