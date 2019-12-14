/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemInfoUI extends ItemBase {
		public var txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/itemInfo");

		}

	}
}