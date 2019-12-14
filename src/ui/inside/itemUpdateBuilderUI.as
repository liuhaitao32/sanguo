/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemUpdateBuilderUI extends ItemBase {
		public var label:Label;
		public var btn_quick:Button;
		public var tStatus:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/itemUpdateBuilder");

		}

	}
}