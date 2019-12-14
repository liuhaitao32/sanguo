/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class fightCountryTurnItemUI extends ItemBase {
		public var heroItem:hero_icon1UI;
		public var textLv:Label;
		public var textIndex:Label;
		public var textPower:Label;
		public var hpBar:ProgressBar;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("battle/fightCountryTurnItem");

		}

	}
}