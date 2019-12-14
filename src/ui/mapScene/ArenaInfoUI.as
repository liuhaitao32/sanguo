/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class ArenaInfoUI extends ItemBase {
		public var bg_img:Image;
		public var icon_img:Sprite;
		public var city_name_txt:Label;
		public var arena_name_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/ArenaInfo");

		}

	}
}