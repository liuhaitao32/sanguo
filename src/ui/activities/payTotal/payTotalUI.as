/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.payTotal {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.payTypeBigUI;

	public class payTotalUI extends ItemBase {
		public var character:hero_icon2UI;
		public var subTitle:Image;
		public var btn_pay:Button;
		public var showList:List;
		public var timeTxt:Label;
		public var payIcon:payTypeBigUI;
		public var btn_suit:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("activities/payTotal/payTotal");

		}

	}
}