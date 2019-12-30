/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemHonourHisUI extends ItemBase {
		public var tTitle:Label;
		public var tTime:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("honour/itemHonourHis");

		}

	}
}