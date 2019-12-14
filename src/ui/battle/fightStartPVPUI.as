/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_power3UI;
	import ui.com.hero_power2UI;
	import ui.hero.formationItemUI;

	public class fightStartPVPUI extends ItemBase {

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_power3UI",hero_power3UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.hero.formationItemUI",formationItemUI);
			super.createChildren();
			loadUI("battle/fightStartPVP");

		}

	}
}