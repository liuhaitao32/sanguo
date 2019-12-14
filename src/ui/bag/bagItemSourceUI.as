/**Created by the LayaAirIDE,do not modify.*/
package ui.bag {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.bag.bagItemUI;
	import ui.bag.item_sourceUI;
	import ui.com.item_titleUI;

	public class bagItemSourceUI extends ViewPanel {
		public var box:Box;
		public var icon:bagItemUI;
		public var _name:Label;
		public var num:Label;
		public var list:List;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.bag.item_sourceUI",item_sourceUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("bag/bagItemSource");

		}

	}
}