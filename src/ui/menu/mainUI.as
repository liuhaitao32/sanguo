/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.menu.bottomUI;
	import ui.menu.topUI;
	import ui.menu.userUI;
	import ui.menu.leftUI;
	import ui.menu.baseUI;

	public class mainUI extends ItemBase {
		public var view_bottom:bottomUI;
		public var view_top:topUI;
		public var view_user:userUI;
		public var view_left:leftUI;
		public var view_base:baseUI;

		override protected function createChildren():void {
			View.regComponent("ui.menu.bottomUI",bottomUI);
			View.regComponent("ui.menu.topUI",topUI);
			View.regComponent("ui.menu.userUI",userUI);
			View.regComponent("ui.menu.leftUI",leftUI);
			View.regComponent("ui.menu.baseUI",baseUI);
			super.createChildren();
			loadUI("menu/main");

		}

	}
}