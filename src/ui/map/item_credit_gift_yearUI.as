/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.rank_inder_img_t_bigUI;

	public class item_credit_gift_yearUI extends ItemBase {
		public var list:List;
		public var comIndex:rank_inder_img_t_bigUI;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			super.createChildren();
			loadUI("map/item_credit_gift_year");

		}

	}
}