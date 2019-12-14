/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class pubProbItemUI extends ItemBase {
		public var heroRatity:Image;
		public var com0:bagItemUI;
		public var infoLabel:Label;
		public var numLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("inside/pubProbItem");

		}

	}
}