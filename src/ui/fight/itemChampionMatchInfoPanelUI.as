/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.fight.itemChampionMatchInfoUI;

	public class itemChampionMatchInfoPanelUI extends ItemBase {
		public var tName0:Label;
		public var tTime1:Label;
		public var tTime0:Label;
		public var p0:itemChampionMatchInfoUI;
		public var p1:itemChampionMatchInfoUI;

		override protected function createChildren():void {
			View.regComponent("ui.fight.itemChampionMatchInfoUI",itemChampionMatchInfoUI);
			super.createChildren();
			loadUI("fight/itemChampionMatchInfoPanel");

		}

	}
}