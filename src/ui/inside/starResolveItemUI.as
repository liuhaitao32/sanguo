/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class starResolveItemUI extends ItemBase {
		public var iconImg:Image;
		public var nameLabel:Label;
		public var numLabel:Label;
		public var lvLabel:Label;
		public var imgSelect:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/starResolveItem");

		}

	}
}