/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class ftask_openUI extends ViewPanel {
		public var list:List;
		public var text1:Label;
		public var text2:Label;
		public var text0:Label;
		public var cityLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("task/ftask_open");

		}

	}
}