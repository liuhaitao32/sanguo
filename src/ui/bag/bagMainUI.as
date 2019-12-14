/**Created by the LayaAirIDE,do not modify.*/
package ui.bag {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class bagMainUI extends ViewScenes {
		public var list:List;
		public var useBtn:Button;
		public var tab:Tab;
		public var text0:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("bag/bagMain");

		}

	}
}