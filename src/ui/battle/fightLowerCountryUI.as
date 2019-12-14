/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightLowerCountryUI extends ItemBase {
		public var btnRank:Button;
		public var btnHelp:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightLowerCountry");

		}

	}
}