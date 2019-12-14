/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.guild.guildTroopinfoItemUI;
	import ui.com.item_titleUI;

	public class guildTroopInfoUI extends ViewPanel {
		public var text0:Label;
		public var btn1:Button;
		public var btn3:Button;
		public var btn2:Button;
		public var numLabel:Label;
		public var text1:Label;
		public var list:List;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.guild.guildTroopinfoItemUI",guildTroopinfoItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("guild/guildTroopInfo");

		}

	}
}