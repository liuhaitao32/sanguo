/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class MiniMap0UI extends ItemBase {
		public var bg_img:Image;
		public var rect_img:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/MiniMap0");

		}

	}
}