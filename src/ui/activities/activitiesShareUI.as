/**Created by the LayaAirIDE,do not modify.*/
package ui.activities {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class activitiesShareUI extends ViewPanel {
		public var imgBG:Image;
		public var btn:Button;
		public var btn_close:Button;
		public var com:bagItemUI;
		public var numLabel:Label;
		public var boxShare:Box;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/activitiesShare");

		}

	}
}