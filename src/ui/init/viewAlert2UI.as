/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class viewAlert2UI extends ViewPanel {
		public var txt:Label;
		public var text0:Label;
		public var btn:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/viewAlert2");

		}

	}
}