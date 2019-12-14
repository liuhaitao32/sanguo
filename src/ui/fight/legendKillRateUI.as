/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.rewardItemUI;

	public class legendKillRateUI extends ViewPanel {
		public var txt_kill:Label;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.activities.rewardItemUI",rewardItemUI);
			super.createChildren();
			loadUI("fight/legendKillRate");

		}

	}
}