/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemCityInfoUI extends ItemBase {
		public var tName:Label;
		public var tNum:Label;
		public var tAll:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/itemCityInfo");

		}

	}
}