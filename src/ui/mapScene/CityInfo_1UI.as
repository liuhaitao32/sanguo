/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class CityInfo_1UI extends ItemBase {
		public var hero_icon:hero_icon1UI;
		public var icon_img:Sprite;
		public var city_name_txt:Label;
		public var user_name_txt:Label;
		public var build_sp:Sprite;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("mapScene/CityInfo_1");

		}

	}
}