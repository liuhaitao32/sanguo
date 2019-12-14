/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class festival_onceUI extends ItemBase {
		public var character:hero_icon2UI;
		public var txt_info:Label;
		public var title:Image;
		public var btn_suit:Button;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("festival/festival_once");

		}

	}
}