/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class troopListUI extends ItemBase {
		public var all:Box;
		public var list:List;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("menu/troopList");

		}

	}
}