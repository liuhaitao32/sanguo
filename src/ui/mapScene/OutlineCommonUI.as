/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class OutlineCommonUI extends ItemBase {
		public var img_bg:Image;
		public var scene_container:Box;
		public var rect_img:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/OutlineCommon");

		}

	}
}