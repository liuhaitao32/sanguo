/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class scenesTitleUI extends ItemBase {
		public var sg_title:Box;
		public var sg_img:Image;
		public var sg_txt:Label;
		public var sg_btn_close:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("menu/scenesTitle");

		}

	}
}