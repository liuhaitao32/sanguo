/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class seasonBaseUI extends ItemBase {
		public var txt_title:Label;
		public var txt_info:Label;
		public var txt_tips:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("menu/seasonBase");

		}

	}
}