/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightCountryHelpUI extends ViewPanel {
		public var panel:Image;
		public var txtTitle:Label;
		public var btnClose:Button;
		public var txtInfo:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightCountryHelp");

		}

	}
}