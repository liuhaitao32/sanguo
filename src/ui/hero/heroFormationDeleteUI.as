/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;
	import ui.com.payTypeUI;

	public class heroFormationDeleteUI extends ViewPanel {
		public var btnDel:Button;
		public var tText:Label;
		public var tTips:Label;
		public var list:List;
		public var comTitle:item_titleUI;
		public var comItem:payTypeUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("hero/heroFormationDelete");

		}

	}
}