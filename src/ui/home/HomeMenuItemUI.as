/**Created by the LayaAirIDE,do not modify.*/
package ui.home {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class HomeMenuItemUI extends ItemBase {
		public var item_btn:Button;
		public var icon_img:Image;
		public var name_txt:Label;
		public var imgWork:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("home/HomeMenuItem");

		}

	}
}