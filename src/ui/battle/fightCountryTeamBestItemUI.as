/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class fightCountryTeamBestItemUI extends ItemBase {
		public var heroItem:hero_icon1UI;
		public var txtTitle:Label;
		public var txtName:Label;
		public var txtInfo:Label;
		public var txtValue:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("battle/fightCountryTeamBestItem");

		}

	}
}