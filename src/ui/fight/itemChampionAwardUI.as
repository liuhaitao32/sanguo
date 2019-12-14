/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.title_hero_sUI;

	public class itemChampionAwardUI extends ItemBase {
		public var awardBox:Box;
		public var rankIcon:rank_inder_img_t_bigUI;
		public var titleIcon:title_hero_sUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.title_hero_sUI",title_hero_sUI);
			super.createChildren();
			loadUI("fight/itemChampionAward");

		}

	}
}