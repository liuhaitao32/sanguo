/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;

	public class viewHintUI extends ViewPanel {
		public var bg:panel_bg_btn_sUI;
		public var txt_content:Label;
		public var comTitle:item_titleUI;
		public var btn0:Button;
		public var btn1:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("init/viewHint");

		}

	}
}