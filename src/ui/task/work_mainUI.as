/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.btn_icon_txt_blueUI;

	public class work_mainUI extends ItemBase {
		public var box_had:Box;
		public var heroIcon:hero_icon2UI;
		public var btn_times:Button;
		public var btn_re:Button;
		public var tTimes:Label;
		public var tInfo:Label;
		public var tReTime:Label;
		public var tTimesHint:Label;
		public var list:List;
		public var boxBottom:Box;
		public var btn_add:Button;
		public var mBox_get:Box;
		public var btn_go:Button;
		public var btn_del:Button;
		public var mBox_ok:Box;
		public var btn_ok:Button;
		public var btn_coin:btn_icon_txt_blueUI;
		public var box_null:Box;
		public var adImg:Image;
		public var btn_times2:Button;
		public var tTalk:Label;
		public var heroIcon2:hero_icon2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.btn_icon_txt_blueUI",btn_icon_txt_blueUI);
			super.createChildren();
			loadUI("task/work_main");

		}

	}
}