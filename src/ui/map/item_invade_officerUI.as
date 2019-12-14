/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_invade_officerUI extends ItemBase {
		public var tName:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/item_invade_officer");

		}

	}
}