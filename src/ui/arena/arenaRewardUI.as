/**Created by the LayaAirIDE,do not modify.*/
package ui.arena {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class arenaRewardUI extends ViewPanel {
		public var box:Box;
		public var img0:Image;
		public var img1:Image;
		public var text:Label;
		public var list:List;
		public var tText:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("arena/arenaReward");

		}

	}
}