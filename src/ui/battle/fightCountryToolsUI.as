/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;

	public class fightCountryToolsUI extends ViewPanel {
		public var boxSpeedUp:Box;
		public var speedUpItem:payTypeUI;
		public var tSpeedUp:Label;
		public var boxCallCar:Box;
		public var callCarItem:payTypeUI;
		public var tCallCar:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("battle/fightCountryTools");

		}

	}
}