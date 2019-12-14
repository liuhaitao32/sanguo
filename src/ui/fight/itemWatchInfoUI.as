/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.fight.itemWatchInfoDataUI;

	public class itemWatchInfoUI extends ItemBase {
		public var tIndex:Label;

		override protected function createChildren():void {
			View.regComponent("ui.fight.itemWatchInfoDataUI",itemWatchInfoDataUI);
			super.createChildren();
			loadUI("fight/itemWatchInfo");

		}

	}
}