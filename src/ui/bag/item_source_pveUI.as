/**Created by the LayaAirIDE,do not modify.*/
package ui.bag {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_source_pveUI extends ItemBase {
		public var btn:Button;
		public var img:Image;
		public var titleLabel:Label;
		public var infoLabel:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("bag/item_source_pve");

		}

	}
}