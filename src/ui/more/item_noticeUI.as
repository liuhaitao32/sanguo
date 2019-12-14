/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class item_noticeUI extends ItemBase {
		public var boxFight:Box;
		public var heroIcon:hero_icon1UI;
		public var boxMove:Box;
		public var cityIcon:Box;
		public var tName:Label;
		public var tInfo:Label;
		public var btn_go:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("more/item_notice");

		}

	}
}