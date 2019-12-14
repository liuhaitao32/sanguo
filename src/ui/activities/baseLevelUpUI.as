/**Created by the LayaAirIDE,do not modify.*/
package ui.activities {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.activities.rewardItemUI;
	import ui.com.payTypeSUI;

	public class baseLevelUpUI extends ViewPanel {
		public var boxEffect:Image;
		public var btn_get:Button;
		public var characterImg:Image;
		public var tabs:Tab;
		public var rewardList:List;
		public var payIcon:payTypeSUI;
		public var titleTxt:Label;
		public var payHintTxt:Label;
		public var tipsTxt:Label;
		public var needMoney:Label;
		public var tipsTxt2:Label;
		public var endHintMc:Box;
		public var endHintTxt:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.activities.rewardItemUI",rewardItemUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			super.createChildren();
			loadUI("activities/baseLevelUp");

		}

	}
}