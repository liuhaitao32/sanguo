/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.hero_icon3UI;

	public class itemHonourRankUI extends ItemBase {
		public var cRank:rank_inder_img_t_bigUI;
		public var cHead:hero_icon3UI;
		public var tName:Label;
		public var tLv:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.hero_icon3UI",hero_icon3UI);
			super.createChildren();
			loadUI("honour/itemHonourRank");

		}

	}
}