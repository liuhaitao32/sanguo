/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_country_store_cityUI extends ItemBase {
		public var tName:Label;
		public var tNum:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/item_country_store_city");

		}

	}
}