/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class country_tributary_tipsUI extends ViewPanel {
		public var text0:Label;
		public var imgTitle:Image;
		public var tTitle:Label;
		public var tText:Label;
		public var infoBox:Box;
		public var tContent:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("countryPvp/country_tributary_tips");

		}

	}
}