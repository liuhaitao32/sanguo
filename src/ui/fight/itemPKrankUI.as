/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.country_flag2UI;

	public class itemPKrankUI extends ItemBase {
		public var tName:Label;
		public var tPower:Label;
		public var award0:bagItemUI;
		public var award1:bagItemUI;
		public var cRank:rank_inder_img_t_bigUI;
		public var countryIcon:country_flag2UI;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			super.createChildren();
			loadUI("fight/itemPKrank");

		}

	}
}