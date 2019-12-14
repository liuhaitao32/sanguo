/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.inside.pubItemUI;

	public class pubMainUI extends ViewScenes {
		public var list:List;
		public var limitText:Label;

		override protected function createChildren():void {
			View.regComponent("ui.inside.pubItemUI",pubItemUI);
			super.createChildren();
			loadUI("inside/pubMain");

		}

	}
}