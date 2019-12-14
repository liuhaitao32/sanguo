/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.country.item_country_stroe_newUI;

	public class country_store_main_newUI extends ItemBase {
		public var list:List;
		public var scene_container:Box;
		public var rect_img:Image;

		override protected function createChildren():void {
			View.regComponent("ui.country.item_country_stroe_newUI",item_country_stroe_newUI);
			super.createChildren();
			loadUI("country/country_store_main_new");

		}

	}
}