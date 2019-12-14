/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class seasonPanelUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var tab:Tab;
		public var img_bg:Image;
		public var img_icon:Image;
		public var list:List;
		public var txt_tips:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("menu/seasonPanel");

		}

	}
}