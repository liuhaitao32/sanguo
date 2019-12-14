/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.battle.fightCountryTurnItemUI;

	public class fightTestHeroesUI extends ViewPanel {
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.battle.fightCountryTurnItemUI",fightCountryTurnItemUI);
			super.createChildren();
			loadUI("battle/fightTestHeroes");

		}

	}
}