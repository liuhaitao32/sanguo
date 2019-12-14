/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class starQuickItemUI extends ItemBase {
		public var nameLabel:Label;
		public var numLabel:Label;
		public var imgIcon:Image;
		public var btnCheck:CheckBox;
		public var text0:Label;
		public var imgSelect:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/starQuickItem");

		}

	}
}