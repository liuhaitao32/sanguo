/**Created by the LayaAirIDE,do not modify.*/
package ui.explore {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_power2UI;
	import ui.com.hero_icon7UI;

	public class item_huntPlaceUI extends ItemBase {
		public var box:Box;
		public var txt_title:Label;
		public var mc_heros:Box;
		public var comPower:hero_power2UI;
		public var txt_hint:Label;
		public var list:List;
		public var mc_time:Box;
		public var mc_radial:Box;
		public var bar_radial:Sprite;
		public var txt_percent:Label;
		public var txt_time:Label;
		public var mc_lock:Box;
		public var txt_lock:Label;
		public var btn_reward:Image;
		public var box_lose:Box;
		public var txt_lose:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_icon7UI",hero_icon7UI);
			super.createChildren();
			loadUI("explore/item_huntPlace");

		}

	}
}