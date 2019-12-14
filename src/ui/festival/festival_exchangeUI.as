/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class festival_exchangeUI extends ItemBase {
		public var character:hero_icon2UI;
		public var list:List;
		public var timerBox:Box;
		public var img_hint:Image;
		public var txt_count_hint:Label;
		public var txt_count:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("festival/festival_exchange");

		}

	}
}