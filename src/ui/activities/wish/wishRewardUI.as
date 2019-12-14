/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.wish {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class wishRewardUI extends ItemBase {
		public var icon:bagItemUI;
		public var tagIcon:Image;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/wish/wishReward");

		}

	}
}