/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import sg.view.com.StarAnimation;

	public class bless_heroUI extends ViewPanel {
		public var box:Box;
		public var btn_help:Button;
		public var imgSuper:Image;
		public var imgAwaken:Image;
		public var heroIcon:hero_icon2UI;
		public var box_reward:Box;
		public var btn_right:Button;
		public var btn_left:Button;
		public var btn:Button;
		public var list_reward:List;
		public var txt_reward:Label;
		public var txt_tips:Label;
		public var txt_times:Label;
		public var txt_times_hint:Label;
		public var txt_rank:Label;
		public var txt_rank_hint:Label;
		public var txt_hurt:Label;
		public var txt_hurt_hint:Label;
		public var btn_rank:Button;
		public var txt_time:Label;
		public var txt_hero_name:Label;
		public var box_star:Box;
		public var mc_star:StarAnimation;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("sg.view.com.StarAnimation",StarAnimation);
			super.createChildren();
			loadUI("map/bless_hero");

		}

	}
}