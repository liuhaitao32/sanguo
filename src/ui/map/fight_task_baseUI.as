/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fight_task_baseUI extends ItemBase {
		public var box_ani:Box;
		public var img_complete:Image;
		public var img_failed:Image;
		public var box_hint:Box;
		public var txt_title:Label;
		public var txt_tips:Label;
		public var txt_buff:Label;
		public var box_ani2:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/fight_task_base");

		}

	}
}