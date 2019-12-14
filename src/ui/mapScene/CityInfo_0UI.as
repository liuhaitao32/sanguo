/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class CityInfo_0UI extends ItemBase {
		public var icon_img:Sprite;
		public var city_name_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/CityInfo_0");

		}

	}
}