/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class ItemActUI extends ItemBase {
		public var imgPanel:Button;
		public var imgIcon:Image;
		public var mcName:Box;
		public var nameLabel:Label;
		public var mcTime:Box;
		public var timeLabel:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("menu/ItemAct");

		}

	}
}