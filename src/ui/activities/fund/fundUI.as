/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.fund {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeBigUI;
	import ui.com.btn_icon_txt_sureUI;

	public class fundUI extends ItemBase {
		public var effectImg:Image;
		public var character:Image;
		public var btn_preview:Button;
		public var desTxt:Image;
		public var list:List;
		public var hintTxt:Label;
		public var totalRewardCoin:Label;
		public var payIcon:payTypeBigUI;
		public var btn_pay:Button;
		public var btn_buy:btn_icon_txt_sureUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("activities/fund/fund");

		}

	}
}