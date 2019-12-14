/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class task_baseUI extends ItemBase {
		public var taskName:Label;
		public var taskInfo:HTMLDivElement;
		public var progressBar:ProgressBar;
		public var btn_go:Button;
		public var btn_reward:Button;
		public var rewardBox:Sprite;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("task/task_base");

		}

	}
}