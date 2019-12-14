/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_overlordUI extends ItemBase {
		public var adImg:Image;
		public var tInfo:Label;
		public var tName:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("more/item_overlord");

		}

	}
}