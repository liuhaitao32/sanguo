/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn1UI;
	import ui.com.item_title1UI;

	public class payTestUI extends ViewPanel {
		public var all:Box;
		public var list:List;
		public var comTitle:item_title1UI;
		public var askBtn:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn1UI",panel_bg_btn1UI);
			View.regComponent("ui.com.item_title1UI",item_title1UI);
			super.createChildren();
			loadUI("menu/payTest");

		}

	}
}