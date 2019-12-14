/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_power2UI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.comCountryOfficialUI;

	public class item_country_rank_newUI extends ItemBase {
		public var imgMayor:Image;
		public var tName:Label;
		public var tOnline:Label;
		public var tNum:Label;
		public var comPower:hero_power2UI;
		public var cRank:rank_inder_img_t_bigUI;
		public var comOfficer:comCountryOfficialUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.comCountryOfficialUI",comCountryOfficialUI);
			super.createChildren();
			loadUI("country/item_country_rank_new");

		}

	}
}