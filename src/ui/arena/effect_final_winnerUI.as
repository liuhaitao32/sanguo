/**Created by the LayaAirIDE,do not modify.*/
package ui.arena {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class effect_final_winnerUI extends ComPayType {
		public var box:Box;
		public var bgImg:Image;
		public var tText:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("arena/effect_final_winner");

		}

	}
}