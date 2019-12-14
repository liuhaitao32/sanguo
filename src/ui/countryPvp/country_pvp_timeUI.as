/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.countryPvp.item_country_pvp_rankUI;
	import ui.bag.bagItemUI;
	import ui.com.item_title_sUI;

	public class country_pvp_timeUI extends ItemBase {
		public var list:List;
		public var timeBox:Box;
		public var timeImg:Image;
		public var tTime:Label;
		public var text1:Label;
		public var bAsk:Button;
		public var text01:Label;
		public var text02:Label;
		public var text03:Label;
		public var text04:Label;
		public var tCredit:Label;
		public var text3:Label;
		public var text2Box:Box;
		public var text2Img:Image;
		public var tNum:Label;
		public var text2:Label;
		public var rlist:List;
		public var bLeft:Box;
		public var bRight:Box;
		public var cTitle:item_title_sUI;
		public var cItem:item_country_pvp_rankUI;
		public var tTips:Label;

		override protected function createChildren():void {
			View.regComponent("ui.countryPvp.item_country_pvp_rankUI",item_country_pvp_rankUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_title_sUI",item_title_sUI);
			super.createChildren();
			loadUI("countryPvp/country_pvp_time");

		}

	}
}