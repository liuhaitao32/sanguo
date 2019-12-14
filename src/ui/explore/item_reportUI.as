/**Created by the LayaAirIDE,do not modify.*/
package ui.explore {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;
	import ui.explore.item_report_armyUI;

	public class item_reportUI extends ItemBase {
		public var img_bg:Image;
		public var img_result:Image;
		public var img_revanche:Image;
		public var box_garbed:Box;
		public var txt_num_hint:Label;
		public var icon_garbed:payTypeUI;
		public var btn_watch:Button;
		public var btn_revanche:Button;
		public var txt_win:Label;
		public var txt_time:Label;
		public var txt_score:Label;
		public var box_1:item_report_armyUI;
		public var box_0:item_report_armyUI;
		public var txt_place:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.explore.item_report_armyUI",item_report_armyUI);
			super.createChildren();
			loadUI("explore/item_report");

		}

	}
}