/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class building_tips8UI extends ComPayType {
		public var icon_img:Image;
		public var txt_bg:Image;
		public var label_txt:Label;
		public var topIcon_img:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/building_tips8");

		}

	}
}