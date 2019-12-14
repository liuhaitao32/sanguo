/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;
	import ui.battle.fightCountryTurnItemUI;

	public class fightCountryTurnUI extends ViewPanel {
		public var flag:country_flag1UI;
		public var txtName:Label;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("ui.battle.fightCountryTurnItemUI",fightCountryTurnItemUI);
			super.createChildren();
			loadUI("battle/fightCountryTurn");

		}

	}
}