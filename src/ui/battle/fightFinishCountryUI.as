/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag3UI;

	public class fightFinishCountryUI extends ViewScenes {
		public var textTitle:Label;
		public var flag:country_flag3UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag3UI",country_flag3UI);
			super.createChildren();
			loadUI("battle/fightFinishCountry");

		}

	}
}