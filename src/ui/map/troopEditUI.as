/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.map.troopEditArmyUI;
	import ui.com.img_c_txt_bUI;
	import ui.com.hero_icon2UI;
	import ui.com.hero_power2UI;
	import ui.com.item_titleUI;

	public class troopEditUI extends ViewPanel {
		public var mBox:Box;
		public var aniBox:Box;
		public var army0:troopEditArmyUI;
		public var army1:troopEditArmyUI;
		public var heroType:img_c_txt_bUI;
		public var box_list:Box;
		public var list:List;
		public var btn_0:Button;
		public var btn_2:Button;
		public var btn_1:Button;
		public var box_lv:Box;
		public var barExp:ProgressBar;
		public var tLvName:Label;
		public var tLv:Label;
		public var tStatus:Label;
		public var tName:Label;
		public var tTime:Label;
		public var cityName:Label;
		public var heroIcon:hero_icon2UI;
		public var comPower:hero_power2UI;
		public var itemTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.map.troopEditArmyUI",troopEditArmyUI);
			View.regComponent("ui.com.img_c_txt_bUI",img_c_txt_bUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/troopEdit");

		}

	}
}