/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import sg.outline.view.OutlineViewCommon;
	import sg.view.map.FightTaskBase;

	public class country_fight_taskUI extends ViewPanel {
		public var mBox:Box;
		public var outline:OutlineViewCommon;
		public var box_time_hint:Box;
		public var txt_time:Label;
		public var txt_time_hint:Label;
		public var txt_merit_add:Label;
		public var txt_title:Label;
		public var txt_tips:Label;
		public var mc_city_0:FightTaskBase;
		public var mc_city_1:FightTaskBase;

		override protected function createChildren():void {
			View.regComponent("sg.outline.view.OutlineViewCommon",OutlineViewCommon);
			View.regComponent("sg.view.map.FightTaskBase",FightTaskBase);
			super.createChildren();
			loadUI("map/country_fight_task");

		}

	}
}