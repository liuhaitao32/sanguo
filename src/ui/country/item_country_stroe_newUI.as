/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_country_stroe_newUI extends ItemBase {
		public var imgFlag:Image;
		public var box0:Box;
		public var box1:Box;
		public var box2:Box;
		public var box3:Box;
		public var box4:Box;
		public var bestBox:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("country/item_country_stroe_new");

		}

	}
}