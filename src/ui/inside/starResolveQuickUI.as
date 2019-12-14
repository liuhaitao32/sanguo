/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.bag.bagItemUI;
	import ui.inside.starQuickItemUI;
	import ui.com.item_titleUI;

	public class starResolveQuickUI extends ViewPanel {
		public var rewardList:List;
		public var starList:List;
		public var btnQuick:Button;
		public var text1:Label;
		public var text0:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.inside.starQuickItemUI",starQuickItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/starResolveQuick");

		}

	}
}