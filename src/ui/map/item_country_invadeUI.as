/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_country_invadeUI extends ItemBase {
		public var bg:Button;
		public var tName:Label;
		public var mSelect:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/item_country_invade");

		}

	}
}