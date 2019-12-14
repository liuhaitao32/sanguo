/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.country_flag1UI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.hero_power2UI;

	public class itemChampionGroupUI extends ItemBase {
		public var heroIcon:hero_icon1UI;
		public var mCountry:country_flag1UI;
		public var tagIndex:rank_inder_img_t_bigUI;
		public var tName:Label;
		public var tagOK:Image;
		public var tWin:Label;
		public var tLose:Label;
		public var comPower:hero_power2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("fight/itemChampionGroup");

		}

	}
}