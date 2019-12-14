/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.country_task_buildUI;
	import laya.html.dom.HTMLDivElement;
	import ui.activities.rewardItemUI;

	public class country_task_mainUI extends ViewPanel {
		public var kingImg:hero_icon2UI;
		public var words_bg2:Image;
		public var wordsTxt:Label;
		public var shouyu:Box;
		public var nameList:List;
		public var progressContainer:Box;
		public var txt_hint_progress:Label;
		public var progressTxt:Label;
		public var progressBar:ProgressBar;
		public var taskName:Label;
		public var taskDescription:Label;
		public var taskTitle:HTMLDivElement;
		public var btn_reward:Button;
		public var progressBar_total:ProgressBar;
		public var btn_build:Button;
		public var rewardList:List;
		public var img_build:Image;
		public var btn_right:Button;
		public var btn_left:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.country_task_buildUI",country_task_buildUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.activities.rewardItemUI",rewardItemUI);
			super.createChildren();
			loadUI("map/country_task_main");

		}

	}
}