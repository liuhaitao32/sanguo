/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class country_officer_tipsUI extends ViewPanel {
		public var adImg:Image;
		public var bgTxt:Image;
		public var img0:Image;
		public var img1:Image;
		public var img2:Image;
		public var tTitle:Label;
		public var lOfficer:Label;
		public var lName:Label;
		public var tOfficer:Label;
		public var tTips:Label;
		public var tName:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("map/country_officer_tips");

		}

	}
}