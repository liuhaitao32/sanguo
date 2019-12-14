/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.payOnce {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class payOnceUI extends ItemBase {
		public var character:hero_icon2UI;
		public var title:Image;
		public var showList:List;
		public var timeTxt:Label;
		public var tipsTxt:Label;
		public var btn_suit:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("activities/payOnce/payOnce");

		}

	}
}