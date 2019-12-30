/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class festivalPanelUI extends ViewPanel {
		public var img_bg:Image;
		public var tabBox:Panel;
		public var tabList:List;
		public var arrow_r:Box;
		public var arrow_l:Box;
		public var mBox:Box;
		public var com_title:Label;
		public var btn_close:Button;
		public var txt_end_time:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("festival/festivalPanel");

		}

	}
}