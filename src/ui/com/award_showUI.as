/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class award_showUI extends ViewPanel {
		public var list:List;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/award_show");

		}

	}
}