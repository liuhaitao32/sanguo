/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class shogunItemUI extends ItemBase {
		public var imgBG:Image;
		public var imgInto:Image;
		public var imgUp:Image;
		public var titleLabel:Label;
		public var scoreLabel:Label;
		public var text0:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/shogunItem");

		}

	}
}