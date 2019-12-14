/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class pveInfoUI extends ViewPanel {
		public var all:Box;
		public var text4:Label;
		public var list:List;
		public var btn0:Button;
		public var btn1:Button;
		public var text1:Label;
		public var text2:Label;
		public var text3:Label;
		public var btn2:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/pveInfo");

		}

	}
}