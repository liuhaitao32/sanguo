/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightSpeakUI extends ItemBase {
		public var imgBg:Image;
		public var tSpeak:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightSpeak");

		}

	}
}