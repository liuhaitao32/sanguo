/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.building_tips101UI;

	public class item_city_buildUI extends ItemBase {
		public var img:Image;
		public var label:Label;
		public var pro:ProgressBar;
		public var imgRatity:Image;
		public var imgSelect:Image;
		public var imgCorner:Image;
		public var imgLock:Box;
		public var imgWork:Image;
		public var comHero:building_tips101UI;
		public var imgTask:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.building_tips101UI",building_tips101UI);
			super.createChildren();
			loadUI("map/item_city_build");

		}

	}
}