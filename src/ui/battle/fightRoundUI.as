/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightRoundUI extends ItemBase {
		public var roundName:Label;
		public var roundIndex:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightRound");

		}

	}
}