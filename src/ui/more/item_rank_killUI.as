/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.hero_icon3UI;

	public class item_rank_killUI extends ItemBase {
		public var comIndex:rank_inder_img_t_bigUI;
		public var cHead:hero_icon3UI;
		public var nameLabel:Label;
		public var numLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.hero_icon3UI",hero_icon3UI);
			super.createChildren();
			loadUI("more/item_rank_kill");

		}

	}
}