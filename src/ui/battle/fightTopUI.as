/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightTopUI extends ItemBase {
		public var btnExit:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightTop");

		}

	}
}