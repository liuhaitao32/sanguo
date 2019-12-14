/**Created by the LayaAirIDE,do not modify.*/
package ui.equip {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemWash1UI extends ItemBase {
		public var tName:Label;
		public var btnRe:Button;
		public var btnUnlock:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("equip/itemWash1");

		}

	}
}