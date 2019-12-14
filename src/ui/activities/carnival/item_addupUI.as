/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class item_addupUI extends ItemBase {
		public var proBar:ProgressBar;
		public var textLabel0:Label;
		public var numImg:Image;
		public var text0:Label;
		public var textLabel1:Label;
		public var imgGet:Image;
		public var rewardCom:bagItemUI;
		public var btnGet:Button;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/carnival/item_addup");

		}

	}
}