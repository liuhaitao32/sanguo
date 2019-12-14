/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.carnival.item_SpartaUI;
	import ui.com.award_box1UI;

	public class happySpartaUI extends ItemBase {
		public var tabList:List;
		public var proBar:ProgressBar;
		public var proLabel:Label;
		public var list:List;
		public var timeBox:Box;
		public var timerImg:Image;
		public var text0:Label;
		public var timerLabel:Label;
		public var comBox:award_box1UI;
		public var pan:Panel;
		public var infoLabel:Label;
		public var boxGet:Box;
		public var boxLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.activities.carnival.item_SpartaUI",item_SpartaUI);
			View.regComponent("ui.com.award_box1UI",award_box1UI);
			super.createChildren();
			loadUI("activities/carnival/happySparta");

		}

	}
}