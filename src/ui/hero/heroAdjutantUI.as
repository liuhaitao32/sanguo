/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class heroAdjutantUI extends ItemBase {
		public var img_bg:Image;
		public var box_commander:Box;
		public var heroIcon:hero_icon2UI;
		public var btn_go:Button;
		public var txt_tips:Label;
		public var box_open:Box;
		public var txt_title_open:Label;
		public var txt_tips1_open:Label;
		public var txt_tips2_open:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("hero/heroAdjutant");

		}

	}
}