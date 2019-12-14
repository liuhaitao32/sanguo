/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.rank_index_img_tUI;
	import ui.com.hero_power2UI;

	public class item_mayor_listUI extends ItemBase {
		public var tName:Label;
		public var tCity:Label;
		public var tOnline:Label;
		public var tNum:Label;
		public var cRank:rank_index_img_tUI;
		public var comPower:hero_power2UI;
		public var icon:Image;
		public var mSelect:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.rank_index_img_tUI",rank_index_img_tUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("map/item_mayor_list");

		}

	}
}