/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn1UI;
	import ui.com.item_title1UI;
	import sg.view.map.BlessHeroRankBase;

	public class bless_hero_rankUI extends ViewPanel {
		public var box_hint:Box;
		public var txt_none:Label;
		public var list:List;
		public var com_title:item_title1UI;
		public var txt_title_name:Label;
		public var txt_title_rank:Label;
		public var txt_title_time:Label;
		public var txt_title_hurt:Label;
		public var txt_tips:Label;
		public var my_rank:BlessHeroRankBase;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn1UI",panel_bg_btn1UI);
			View.regComponent("ui.com.item_title1UI",item_title1UI);
			View.regComponent("sg.view.map.BlessHeroRankBase",BlessHeroRankBase);
			super.createChildren();
			loadUI("map/bless_hero_rank");

		}

	}
}