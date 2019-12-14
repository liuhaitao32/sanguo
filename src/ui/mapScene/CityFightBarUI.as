/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag2UI;

	public class CityFightBarUI extends ItemBase {
		public var box:Box;
		public var bg0:Image;
		public var bg1:Image;
		public var barBox:Box;
		public var country0:country_flag2UI;
		public var country1:country_flag2UI;
		public var num0:Label;
		public var num1:Label;
		public var cityName:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			super.createChildren();
			loadUI("mapScene/CityFightBar");

		}

	}
}