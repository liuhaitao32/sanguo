/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class festival_pitupUI extends ItemBase {
		public var character:hero_icon2UI;
		public var img_bg:Image;
		public var img_reward_panel:Image;
		public var btn_reward:Button;
		public var txt_progress:Label;
		public var txt_pay:Label;
		public var txt_hint:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("festival/festival_pitup");

		}

	}
}