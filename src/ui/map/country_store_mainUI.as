/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class country_store_mainUI extends ItemBase {
		public var list:List;
		public var listCity:List;
		public var scene_container:Box;
		public var rect_img:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/country_store_main");

		}

	}
}