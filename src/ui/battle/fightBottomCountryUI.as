/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightBottomCountryUI extends ItemBase {
		public var bg:Image;
		public var btnTimeScale:Button;
		public var btnNextFight:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightBottomCountry");

		}

	}
}