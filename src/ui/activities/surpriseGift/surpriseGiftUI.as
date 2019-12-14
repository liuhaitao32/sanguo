/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.surpriseGift {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class surpriseGiftUI extends ViewPanel {
		public var box:Box;
		public var btn_help:Button;
		public var list:List;
		public var txt_time:Label;
		public var txt_tips2:Label;
		public var txt_time_hint:Label;
		public var box_tips:Box;
		public var txt_tips:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("activities/surpriseGift/surpriseGift");

		}

	}
}