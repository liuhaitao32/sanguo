/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.battle.fightTestFormationUI;

	public class fightTestTableRateItemUI extends ItemBase {
		public var imgChoose:Image;
		public var tWin:Label;
		public var tSelf:Label;
		public var tEnemy:Label;
		public var tRound:Label;
		public var tHeroName:Label;
		public var tEnemyName:Label;
		public var fSelf:fightTestFormationUI;
		public var fEnemy:fightTestFormationUI;

		override protected function createChildren():void {
			View.regComponent("ui.battle.fightTestFormationUI",fightTestFormationUI);
			super.createChildren();
			loadUI("battle/fightTestTableRateItem");

		}

	}
}