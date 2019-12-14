/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.skillItemUI;
	import ui.com.item_titleUI;

	public class propResolveCheckUI extends ViewPanel {
		public var pan:Panel;
		public var box1:Box;
		public var skillList1:List;
		public var nameLabel1:Label;
		public var box2:Box;
		public var skillList2:List;
		public var nameLabel2:Label;
		public var box3:Box;
		public var skillList3:List;
		public var nameLabel3:Label;
		public var box4:Box;
		public var skillList4:List;
		public var nameLabel4:Label;
		public var btn:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.skillItemUI",skillItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/propResolveCheck");

		}

	}
}