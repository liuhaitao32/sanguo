/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.bag.bagItemUI;

	public class ftask_mainUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var img0:Image;
		public var text0:Label;
		public var infoLabel:Label;
		public var comItem:bagItemUI;
		public var btn0:Button;
		public var btn1:Button;
		public var btn2:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("task/ftask_main");

		}

	}
}