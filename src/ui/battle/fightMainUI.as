/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.battle.fightBottomUI;
	import ui.battle.fightTitleUI;

	public class fightMainUI extends ViewScenes {
		public var bottomUI:fightBottomUI;
		public var titleUI:fightTitleUI;

		override protected function createChildren():void {
			View.regComponent("ui.battle.fightBottomUI",fightBottomUI);
			View.regComponent("ui.battle.fightTitleUI",fightTitleUI);
			super.createChildren();
			loadUI("battle/fightMain");

		}

	}
}