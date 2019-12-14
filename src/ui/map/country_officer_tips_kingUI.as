/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class country_officer_tips_kingUI extends ViewPanel {
		public var adImg:Image;
		public var imgTitle:Image;
		public var tTitle:Label;
		public var tName:HTMLDivElement;
		public var tText:Label;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("map/country_officer_tips_king");

		}

	}
}