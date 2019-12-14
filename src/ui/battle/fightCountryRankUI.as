/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightCountryRankUI extends ViewPanel {
		public var panel:Image;
		public var txtTitle:Label;
		public var btnClose:Button;
		public var tab:Tab;
		public var txtIndex:Label;
		public var txtName:Label;
		public var txtKill:Label;
		public var list:List;
		public var imgMyTroop:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightCountryRank");

		}

	}
}