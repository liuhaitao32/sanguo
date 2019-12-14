/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.fight.itemPKrankUI;
	import ui.com.item_titleUI;

	public class pkRankUI extends ViewPanel {
		public var list:List;
		public var text0:Label;
		public var text1:Label;
		public var text2:Label;
		public var text3:Label;
		public var tPage:Label;
		public var mSelf:itemPKrankUI;
		public var btn_back:Button;
		public var btn_add:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.fight.itemPKrankUI",itemPKrankUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("fight/pkRank");

		}

	}
}