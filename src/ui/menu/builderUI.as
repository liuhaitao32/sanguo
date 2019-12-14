/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class builderUI extends ItemBase {
		public var img:Image;
		public var bgTimer:Image;
		public var bgTxt:Image;
		public var txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("menu/builder");

		}

	}
}