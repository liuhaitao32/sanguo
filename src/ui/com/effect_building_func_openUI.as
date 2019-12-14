/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class effect_building_func_openUI extends ComPayType {
		public var adImg:Image;
		public var tTitle:Image;
		public var bg:Image;
		public var tName:Label;
		public var tInfo:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/effect_building_func_open");

		}

	}
}