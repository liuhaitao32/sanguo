/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;

	public class cityInfoListUI extends ViewPanel {
		public var mBox:Box;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			super.createChildren();
			loadUI("map/cityInfoList");

		}

	}
}