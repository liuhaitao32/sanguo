/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class btnBeastUI extends ItemBase {
		public var img1:Image;
		public var img0:Image;
		public var tName:Label;
		public var aniBox:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("hero/btnBeast");

		}

	}
}