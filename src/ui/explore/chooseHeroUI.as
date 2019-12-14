/**Created by the LayaAirIDE,do not modify.*/
package ui.explore {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class chooseHeroUI extends ViewPanel {
		public var box_list:Box;
		public var list:List;
		public var btn:Button;
		public var txt_hint:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("explore/chooseHero");

		}

	}
}