/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.img_c_txt_bUI;
	import ui.com.hero_power2UI;

	public class guildTroopinfoItemUI extends ItemBase {
		public var heroIcon:hero_icon1UI;
		public var uNameLabel:Label;
		public var armyLabel:Label;
		public var pro:ProgressBar;
		public var hNameLabel:Label;
		public var indexLabel:Label;
		public var btn0:Button;
		public var comType:img_c_txt_bUI;
		public var comPower:hero_power2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.img_c_txt_bUI",img_c_txt_bUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("guild/guildTroopinfoItem");

		}

	}
}