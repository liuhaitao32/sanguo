/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.city_func_iconUI;
	import ui.com.hero_lv3UI;

	public class CityTroopBarUI extends ItemBase {
		public var npc_txt:Label;
		public var user_txt:Label;
		public var com1:city_func_iconUI;
		public var com0:city_func_iconUI;
		public var comLv:hero_lv3UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.city_func_iconUI",city_func_iconUI);
			View.regComponent("ui.com.hero_lv3UI",hero_lv3UI);
			super.createChildren();
			loadUI("mapScene/CityTroopBar");

		}

	}
}