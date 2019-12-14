/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class legendBaseUI extends ItemBase {
		public var box_road:Box;
		public var character_road:hero_icon2UI;
		public var img_foreshow:Image;
		public var txt_name_road:Label;
		public var txt_info_road:Label;
		public var bar:ProgressBar;
		public var box_experience:Box;
		public var character_experience:hero_icon2UI;
		public var txt_name_experience:Label;
		public var txt_info_experience:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("fight/legendBase");

		}

	}
}