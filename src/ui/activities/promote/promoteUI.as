/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.promote {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.activities.promote.promoteRewardBaseUI;
	import ui.com.payTypeBigUI;

	public class promoteUI extends ItemBase {
		public var btn_pay:Button;
		public var character:hero_icon2UI;
		public var rewardList:List;
		public var payIcon:payTypeBigUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.activities.promote.promoteRewardBaseUI",promoteRewardBaseUI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("activities/promote/promote");

		}

	}
}