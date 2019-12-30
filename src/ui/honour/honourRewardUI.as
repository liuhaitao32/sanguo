/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class honourRewardUI extends ViewPanel {

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("honour/honourReward");

		}

	}
}