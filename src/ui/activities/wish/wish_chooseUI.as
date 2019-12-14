/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.wish {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class wish_chooseUI extends ViewPanel {
		public var choosePool:List;
		public var rewardList:List;
		public var btn_wish:Button;
		public var chooseTips:Label;
		public var chooseTxt:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("activities/wish/wish_choose");

		}

	}
}