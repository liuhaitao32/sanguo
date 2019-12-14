/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_server_listUI extends ItemBase {
		public var txt:Label;
		public var s2:Button;
		public var s0:Button;
		public var s1:Button;
		public var tag0:Image;
		public var tag1:Image;
		public var tag2:Image;
		public var tag3:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/item_server_list");

		}

	}
}