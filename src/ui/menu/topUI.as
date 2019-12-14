/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;

	public class topUI extends ItemBase {
		public var merit:Button;
		public var merit_var:payTypeUI;
		public var gold:Button;
		public var gold_var:payTypeUI;
		public var food:Button;
		public var food_var:payTypeUI;
		public var wood:Button;
		public var wood_var:payTypeUI;
		public var iron:Button;
		public var iron_var:payTypeUI;
		public var coin:Button;
		public var coin_add:Image;
		public var coin_var:payTypeUI;
		public var coin_red:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("menu/top");

		}

	}
}