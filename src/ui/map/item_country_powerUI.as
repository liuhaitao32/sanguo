/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeSUI;

	public class item_country_powerUI extends ItemBase {
		public var c0:Image;
		public var c1:Image;
		public var c2:Image;
		public var goldIcon:payTypeSUI;
		public var foodIcon:payTypeSUI;
		public var txt_title:Label;
		public var tNum:Label;
		public var txt_hint0:Label;
		public var txt_hint1:Label;
		public var tct4:Label;
		public var tct3:Label;
		public var tct1:Label;
		public var tct2:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			super.createChildren();
			loadUI("map/item_country_power");

		}

	}
}