/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class climbTroopUI extends ViewPanel {
		public var box_list:Box;
		public var list:List;
		public var btn_fight:Button;
		public var text1:Label;
		public var comTitle:item_titleUI;
		public var box_hint:Box;
		public var tStatus:Label;
		public var text0:Label;
		public var mc_tips:Box;
		public var txt_tips:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("fight/climbTroop");

		}

	}
}