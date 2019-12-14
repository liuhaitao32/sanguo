/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.hero_icon3UI;
	import ui.com.country_flag2UI;
	import ui.com.city_func_iconUI;
	import ui.com.country_flag1UI;
	import ui.com.item_titleUI;

	public class cityInfoUI extends ViewPanel {
		public var mBox:Box;
		public var heroIcon:hero_icon3UI;
		public var mCountry:country_flag2UI;
		public var list:List;
		public var item_3:Label;
		public var tFood:Label;
		public var item_2:Label;
		public var tGold:Label;
		public var item_1:Label;
		public var tCoin:Label;
		public var buff1:city_func_iconUI;
		public var buff2:city_func_iconUI;
		public var buff3:city_func_iconUI;
		public var buff4:city_func_iconUI;
		public var flag3:country_flag1UI;
		public var flag4:country_flag1UI;
		public var tMayor:Label;
		public var tTeam:Label;
		public var tArmy:Label;
		public var tLv:Label;
		public var item_4:Label;
		public var item_5:Label;
		public var item_6:Label;
		public var item_7:Label;
		public var tNpc:Label;
		public var tNpcAll:Label;
		public var cityType:Label;
		public var tInfo:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.hero_icon3UI",hero_icon3UI);
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			View.regComponent("ui.com.city_func_iconUI",city_func_iconUI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/cityInfo");

		}

	}
}