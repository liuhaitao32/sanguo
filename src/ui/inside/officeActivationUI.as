/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.inside.officePrivilegeUI;
	import ui.com.item_titleUI;

	public class officeActivationUI extends ViewPanel {
		public var mBox:Box;
		public var mIcon:officePrivilegeUI;
		public var tName:Label;
		public var tText:Label;
		public var tInfo:Label;
		public var btn:Button;
		public var tStatus:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.inside.officePrivilegeUI",officePrivilegeUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/officeActivation");

		}

	}
}