/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon6UI;

	public class building_tips5UI extends ComPayType {
		public var icon:hero_icon6UI;
		public var effect_sp:Sprite;
		public var flag_container:Box;
		public var flag_img:Image;
		public var flag_txt:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon6UI",hero_icon6UI);
			super.createChildren();
			loadUI("com/building_tips5");

		}

	}
}