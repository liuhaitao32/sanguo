/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class item_country_pvp_countryUI extends ItemBase {
		public var imgFlag:Image;
		public var rankBox:Box;
		public var imgColor1:Image;
		public var imgColor2:Image;
		public var imgRank:Image;
		public var list:List;
		public var box1:Box;
		public var img1:Image;
		public var tNum1:Label;
		public var text1:Label;
		public var box2:Box;
		public var img2:Image;
		public var tNum2:Label;
		public var text2:Label;
		public var com0:Box;
		public var com1:Box;
		public var com2:Box;
		public var com3:Box;
		public var com4:Box;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("countryPvp/item_country_pvp_country");

		}

	}
}