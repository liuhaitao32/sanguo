/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class MiniMapTop2UI extends ViewPanel {
		public var boxMain:Box;
		public var cTitle:item_titleUI;
		public var scene_container:Sprite;
		public var rect_img:Image;
		public var bottomContainer:Box;
		public var filter_btn:Button;
		public var select_img:Image;
		public var btnContainer:Box;
		public var btns_bg_img:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("mapScene/MiniMapTop2");

		}

	}
}