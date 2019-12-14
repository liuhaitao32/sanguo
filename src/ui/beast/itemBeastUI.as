/**Created by the LayaAirIDE,do not modify.*/
package ui.beast {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemBeastUI extends ItemBase {
		public var imgIcon:Image;
		public var imgRatity:Image;
		public var imgLv:Image;
		public var tLv:Label;
		public var boxPos:Box;
		public var imgPos:Image;
		public var btnChoose:Button;
		public var btnLock:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("beast/itemBeast");

		}

	}
}