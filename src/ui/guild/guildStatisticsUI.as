/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class guildStatisticsUI extends ViewPanel {
		public var list1:List;
		public var list2:List;
		public var btn:Button;
		public var text0:Label;
		public var text1:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("guild/guildStatistics");

		}

	}
}