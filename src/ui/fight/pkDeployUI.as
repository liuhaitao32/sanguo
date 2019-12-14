/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.payTypeSUI;
	import ui.com.item_titleUI;

	public class pkDeployUI extends ViewPanel {
		public var mBox:Box;
		public var tName:Label;
		public var tOther:Label;
		public var btn:Button;
		public var boxReward:Box;
		public var text0:Label;
		public var award:payTypeSUI;
		public var btnClear:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("fight/pkDeploy");

		}

	}
}