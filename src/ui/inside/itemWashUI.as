/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemWashUI extends ItemBase {
		public var nameLabel:Label;
		public var btnRe:Button;
		public var btnUnlock:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/itemWash");

		}

	}
}