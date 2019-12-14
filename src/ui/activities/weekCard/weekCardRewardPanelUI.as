/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.weekCard {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class weekCardRewardPanelUI extends ViewPanel {
		public var box:Box;
		public var bg:Image;
		public var reward:bagItemUI;
		public var remainDays:Label;
		public var closehint:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/weekCard/weekCardRewardPanel");

		}

	}
}