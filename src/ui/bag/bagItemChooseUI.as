/**Created by the LayaAirIDE,do not modify.*/
package ui.bag {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class bagItemChooseUI extends ViewPanel {
		public var allBox:Box;
		public var list:List;
		public var comTitle:item_titleUI;
		public var list2:List;
		public var box0:Box;
		public var tLabel:Label;
		public var btnUse:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("bag/bagItemChoose");

		}

	}
}