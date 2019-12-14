/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class MiniMapTopUI extends ViewScenes {
		public var scene_container:Sprite;
		public var rect_img:Image;
		public var bottomContainer:Box;
		public var filter_btn:Button;
		public var select_img:Image;
		public var btnContainer:Box;
		public var btns_bg_img:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/MiniMapTop");

		}

	}
}