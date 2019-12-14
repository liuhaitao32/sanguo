/**Created by the LayaAirIDE,do not modify.*/
package ui.bag {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_sourceUI extends ItemBase {
		public var btn:Button;
		public var img:Image;
		public var titleLabel:Label;
		public var info:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("bag/item_source");

		}

	}
}