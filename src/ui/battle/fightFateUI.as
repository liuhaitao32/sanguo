/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightFateUI extends ItemBase {
		public var label:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightFate");

		}

	}
}