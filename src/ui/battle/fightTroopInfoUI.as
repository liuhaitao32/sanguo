/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.battle.fightTroopBgUI;
	import ui.com.country_flag2UI;
	import ui.com.hero_icon1UI;
	import ui.battle.fightBeastItemUI;

	public class fightTroopInfoUI extends ComPayType {
		public var bg:fightTroopBgUI;
		public var hpBar:ProgressBar;
		public var country:country_flag2UI;
		public var heroIcon:hero_icon1UI;
		public var imgAdept:Image;
		public var imgFirst:Image;
		public var txtOfficial:Label;
		public var txtProud:Label;
		public var txtFormation:Label;
		public var txtTest:Label;
		public var beast1:fightBeastItemUI;
		public var beast0:fightBeastItemUI;

		override protected function createChildren():void {
			View.regComponent("ui.battle.fightTroopBgUI",fightTroopBgUI);
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.battle.fightBeastItemUI",fightBeastItemUI);
			super.createChildren();
			loadUI("battle/fightTroopInfo");

		}

	}
}