/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.award_box5UI;

	public class festival_addupUI extends ItemBase {
		public var comBox:award_box5UI;
		public var txt_time_hint:Label;
		public var txt_time:Label;
		public var txt_big_need:Label;
		public var txt_pay_hint:Label;
		public var txt_pay:Label;
		public var showList:List;
		public var img_loop_panel:Image;
		public var btn_loop_reward:Button;
		public var bar_loop:ProgressBar;
		public var txt_loop_hint:Label;
		public var txt_loop_reward:Label;
		public var txt_progress:Label;
		public var txt_progress_hint:Label;
		public var btn_help:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.award_box5UI",award_box5UI);
			super.createChildren();
			loadUI("festival/festival_addup");

		}

	}
}