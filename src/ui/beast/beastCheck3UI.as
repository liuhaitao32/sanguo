/**Created by the LayaAirIDE,do not modify.*/
package ui.beast {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class beastCheck3UI extends ViewPanel {
		public var imgName:Image;
		public var tName:Label;
		public var list:List;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("beast/beastCheck3");

		}

	}
}