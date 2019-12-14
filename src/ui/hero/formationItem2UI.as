/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class formationItem2UI extends ItemBase {
		public var imgBg:Image;
		public var imgIcon:Image;
		public var tName:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("hero/formationItem2");

		}

	}
}