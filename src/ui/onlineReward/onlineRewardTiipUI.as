/**Created by the LayaAirIDE,do not modify.*/
package ui.onlineReward {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class onlineRewardTiipUI extends ItemBase {
		public var giftIcon:Image;
		public var timeTxt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("onlineReward/onlineRewardTiip");

		}

	}
}