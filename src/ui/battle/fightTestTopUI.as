/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeTestUI;

	public class fightTestTopUI extends ItemBase {
		public var btnChapter:Button;
		public var gold_var:payTypeTestUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeTestUI",payTypeTestUI);
			super.createChildren();
			loadUI("battle/fightTestTop");

		}

	}
}