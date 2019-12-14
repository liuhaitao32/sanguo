/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_country_mayorUI extends ItemBase {
		public var tName:Label;
		public var tType:Label;
		public var tNum:Label;
		public var tMayor:Label;
		public var tTeam:Label;
		public var icon:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/item_country_mayor");

		}

	}
}