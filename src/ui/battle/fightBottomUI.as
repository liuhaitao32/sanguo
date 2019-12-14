/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightBottomUI extends ItemBase {
		public var bg:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightBottom");

		}

	}
}