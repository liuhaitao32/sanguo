/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.memberCard {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class memberCardUI extends ItemBase {
		public var txt_price:Label;
		public var img_activate:Image;
		public var img_hint:Image;
		public var reward_list_day:List;
		public var reward_list_total:List;
		public var btn_pay:Button;
		public var btn_help:Button;
		public var txt_tips:Label;
		public var txt_hint:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/memberCard/memberCard");

		}

	}
}