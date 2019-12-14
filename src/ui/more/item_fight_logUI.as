/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;

	public class item_fight_logUI extends ItemBase {
		public var btn:Button;
		public var icon:Image;
		public var tName:Label;
		public var tTime:Label;
		public var award:payTypeUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("more/item_fight_log");

		}

	}
}