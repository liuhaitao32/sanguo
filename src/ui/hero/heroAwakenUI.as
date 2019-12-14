/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class heroAwakenUI extends ViewPanel {
		public var ani_hero:FrameAnimation;
		public var box_b:Box;
		public var box_hero:Box;
		public var icon_hero:hero_icon2UI;
		public var icon_hero_w:hero_icon2UI;
		public var box_f:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("hero/heroAwaken");

		}

	}
}