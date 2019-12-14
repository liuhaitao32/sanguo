/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class formationItemUI extends ItemBase {
		public var imgBg:Image;
		public var imgIcon:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("hero/formationItem");

		}

	}
}