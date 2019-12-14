/**Created by the LayaAirIDE,do not modify.*/
package ui.bag {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class bagItemUseUI extends ViewPanel {
		public var btnUse:Button;
		public var icon:bagItemUI;
		public var _name:Label;
		public var haveNum:Label;
		public var text1:Label;
		public var useNum:Label;
		public var slider:HSlider;
		public var btnBig:Button;
		public var btnAdd:Button;
		public var btnReduse:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("bag/bagItemUse");

		}

	}
}