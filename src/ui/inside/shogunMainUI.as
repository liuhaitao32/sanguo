/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.inside.shogunItemUI;

	public class shogunMainUI extends ViewScenes {
		public var titleLabel:Label;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.inside.shogunItemUI",shogunItemUI);
			super.createChildren();
			loadUI("inside/shogunMain");

		}

	}
}