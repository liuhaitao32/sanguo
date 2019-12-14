/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class task_listUI extends ItemBase {
		public var imgBg:Image;
		public var list:List;
		public var topBar:Box;
		public var btn_get:Button;
		public var box_tips:Box;
		public var hint_progress:Label;
		public var txt_progress:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("task/task_list");

		}

	}
}