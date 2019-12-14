/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class country_emperor_tipsUI extends ViewPanel {
		public var text1:Label;
		public var text0:Label;
		public var list:List;
		public var tName:Label;
		public var tCountry:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("countryPvp/country_emperor_tips");

		}

	}
}