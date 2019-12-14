/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightLowerUI extends ItemBase {
		public var btnTimeScale:Button;
		public var btnTimeImg:Image;
		public var btnNextFight:Button;
		public var btnHelp:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightLower");

		}

	}
}