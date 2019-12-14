/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_carUI extends ItemBase {
		public var box0:Box;
		public var text0:Label;
		public var boxSelect:Box;
		public var box1:Box;
		public var text1:Label;
		public var aniBox:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("countryPvp/item_car");

		}

	}
}