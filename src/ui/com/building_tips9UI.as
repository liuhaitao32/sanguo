/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon5UI;

	public class building_tips9UI extends ComPayType {
		public var icon:hero_icon5UI;
		public var icon_img:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon5UI",hero_icon5UI);
			super.createChildren();
			loadUI("com/building_tips9");

		}

	}
}