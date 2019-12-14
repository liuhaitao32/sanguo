/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class task_mainUI extends ViewScenes {
		public var box:Box;
		public var tab:Tab;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("task/task_main");

		}

	}
}