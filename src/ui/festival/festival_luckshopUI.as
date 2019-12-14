/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class festival_luckshopUI extends ItemBase {
		public var btn_refresh:Button;
		public var btn_img:Image;
		public var btn_txt:Label;
		public var txt_refresh_times:Label;
		public var character:hero_icon2UI;
		public var list:List;
		public var box_hint:Box;
		public var img_remain_times:Image;
		public var txt_times_hint:Label;
		public var txt_remain_times:Label;
		public var timerBox:Box;
		public var img_count:Image;
		public var txt_count_hint:Label;
		public var txt_count:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("festival/festival_luckshop");

		}

	}
}