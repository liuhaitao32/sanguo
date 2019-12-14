/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.bag.bagItemUI;

	public class itemRankUI extends ItemBase {
		public var bg:Image;
		public var tName:Label;
		public var tKill:Label;
		public var countryIcon:country_flag1UI;
		public var rankCom:rank_inder_img_t_bigUI;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("fight/itemRank");

		}

	}
}