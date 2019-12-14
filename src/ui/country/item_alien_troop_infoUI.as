/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.hero_power2UI;
	import ui.com.army_icon1UI;
	import ui.com.img_c_txt_cUI;

	public class item_alien_troop_infoUI extends ItemBase {
		public var imgBG:Image;
		public var heroIcon:hero_icon1UI;
		public var uNameLabel:Label;
		public var indexLabel:Label;
		public var btn0:Button;
		public var comPower:hero_power2UI;
		public var comArmy1:army_icon1UI;
		public var comArmy0:army_icon1UI;
		public var comType:img_c_txt_cUI;
		public var lvLabel:Label;
		public var hNameLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.army_icon1UI",army_icon1UI);
			View.regComponent("ui.com.img_c_txt_cUI",img_c_txt_cUI);
			super.createChildren();
			loadUI("country/item_alien_troop_info");

		}

	}
}