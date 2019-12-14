/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class building_tips10UI extends ComPayType {
		public var icon_img:Image;
		public var effect_sp:Sprite;
		public var label_txt:Label;
		public var flag_container:Box;
		public var flag_img:Image;
		public var flag_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/building_tips10");

		}

	}
}