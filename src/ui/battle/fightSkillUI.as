/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon_fight_skillUI;

	public class fightSkillUI extends ItemBase {
		public var image:Image;
		public var heroIcon:hero_icon_fight_skillUI;
		public var label:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon_fight_skillUI",hero_icon_fight_skillUI);
			super.createChildren();
			loadUI("battle/fightSkill");

		}

	}
}