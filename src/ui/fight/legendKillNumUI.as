/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class legendKillNumUI extends ViewPanel {
		public var txt_kill:Label;
		public var txt_hint:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("fight/legendKillNum");

		}

	}
}