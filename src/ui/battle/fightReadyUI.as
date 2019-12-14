/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightReadyUI extends ItemBase {
		public var labelInfo:Label;
		public var labelTime:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightReady");

		}

	}
}