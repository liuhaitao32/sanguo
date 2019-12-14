/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.memberCard {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class memberCardRewardPanelUI extends ViewPanel {
		public var box:Box;
		public var bg:Image;
		public var btn_get:Button;
		public var list:List;
		public var btn_help:Button;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/memberCard/memberCardRewardPanel");

		}

	}
}