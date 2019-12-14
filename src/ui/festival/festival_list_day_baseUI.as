/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class festival_list_day_baseUI extends ItemBase {
		public var img_blue:Image;
		public var img_red:Image;
		public var txt_0:Label;
		public var txt_1:Label;
		public var img_shadow:Image;
		public var img_receive:Image;
		public var img_overdue:Image;
		public var txt_day:Label;
		public var box_current:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("festival/festival_list_day_base");

		}

	}
}