/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeBigUI;

	public class armyUpgradeAlertUI extends ViewPanel {
		public var img0:Image;
		public var btn0:Button;
		public var btn1:Button;
		public var text1:Label;
		public var text0:Label;
		public var com0:payTypeBigUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("inside/armyUpgradeAlert");

		}

	}
}