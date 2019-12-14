/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.fight.itemTroopUI;
	import ui.com.item_titleUI;
	import ui.com.hero_power2UI;

	public class guildTroopUI extends ViewPanel {
		public var btnOK:Button;
		public var list:List;
		public var text3:Label;
		public var box0:Box;
		public var text2:Label;
		public var text4:Label;
		public var comTitle:item_titleUI;
		public var box1:Box;
		public var comPower:hero_power2UI;
		public var text5:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.fight.itemTroopUI",itemTroopUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("guild/guildTroop");

		}

	}
}