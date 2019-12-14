/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class science_mainUI extends ViewScenes {
		public var list:List;
		public var box_unlock:Box;
		public var tUnlock:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/science_main");

		}

	}
}