/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_country_mayor_newUI extends ItemBase {
		public var tName:Label;
		public var tType:Label;
		public var tNum:Label;
		public var tMayor:Label;
		public var icon:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("country/item_country_mayor_new");

		}

	}
}