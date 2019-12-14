/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.map.item_country_rankUI;

	public class country_rank_mainUI extends ItemBase {
		public var tab:Tab;
		public var mSelf:item_country_rankUI;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.map.item_country_rankUI",item_country_rankUI);
			super.createChildren();
			loadUI("map/country_rank_main");

		}

	}
}