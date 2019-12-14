/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemPreUI extends ItemBase {
		public var btn_go:Button;
		public var txt:Label;
		public var tInfo:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/itemPre");

		}

	}
}