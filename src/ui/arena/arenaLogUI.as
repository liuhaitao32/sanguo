/**Created by the LayaAirIDE,do not modify.*/
package ui.arena {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.arena.itemArenaLogUI;

	public class arenaLogUI extends ViewScenes {
		public var tab1:Tab;
		public var tab2:Tab;
		public var list:List;
		public var textTips:Label;

		override protected function createChildren():void {
			View.regComponent("ui.arena.itemArenaLogUI",itemArenaLogUI);
			super.createChildren();
			loadUI("arena/arenaLog");

		}

	}
}