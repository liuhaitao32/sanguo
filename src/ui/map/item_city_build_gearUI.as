/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_city_build_gearUI extends ItemBase {
		public var label0:Label;
		public var label1:Label;
		public var imgSelect:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/item_city_build_gear");

		}

	}
}