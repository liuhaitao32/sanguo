/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.battle.fightTestTroopSkillItemUI;

	public class fightTestTroopSkillUI extends ViewPanel {
		public var list:List;
		public var btn:Button;

		override protected function createChildren():void {
			View.regComponent("ui.battle.fightTestTroopSkillItemUI",fightTestTroopSkillItemUI);
			super.createChildren();
			loadUI("battle/fightTestTroopSkill");

		}

	}
}