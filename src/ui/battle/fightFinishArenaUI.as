/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightFinishArenaUI extends ViewScenes {
		public var panel:Image;
		public var btnReplay:Button;
		public var imgReplay:Image;
		public var btnExit:Button;
		public var imgExit:Image;
		public var btnNext:Button;
		public var imgNext:Image;
		public var textTitle:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightFinishArena");

		}

	}
}