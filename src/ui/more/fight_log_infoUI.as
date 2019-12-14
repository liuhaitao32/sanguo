/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.payTypeUI;
	import ui.com.payTypeSUI;
	import ui.com.item_titleUI;

	public class fight_log_infoUI extends ViewPanel {
		public var boxPapa:Box;
		public var iconDiff:Image;
		public var iconAtt:Image;
		public var cDiff:Image;
		public var cAtt:Image;
		public var award:payTypeUI;
		public var guanbi:Label;
		public var t1:Label;
		public var iAward:Label;
		public var tCity:Label;
		public var tNameDiff:Label;
		public var tNameAtt:Label;
		public var boxTeam:Box;
		public var iTeamAward:Label;
		public var coin:payTypeSUI;
		public var gold:payTypeSUI;
		public var food:payTypeSUI;
		public var iArmy:Label;
		public var tArmy:Label;
		public var iTeam:Label;
		public var tTeam:Label;
		public var iKill:Label;
		public var tKill:Label;
		public var iDel:Label;
		public var tDel:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("more/fight_log_info");

		}

	}
}