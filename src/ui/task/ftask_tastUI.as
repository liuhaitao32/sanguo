/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;

	public class ftask_tastUI extends ViewPanel {
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			super.createChildren();
			loadUI("task/ftask_tast");

		}

	}
}