/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;

	public class fightCountryRankItemUI extends ItemBase {
		public var img:Image;
		public var txtIndex:Label;
		public var txtName:Label;
		public var txtKill:Label;
		public var flag:country_flag1UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("battle/fightCountryRankItem");

		}

	}
}