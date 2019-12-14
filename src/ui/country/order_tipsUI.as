/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class order_tipsUI extends ViewPanel {
		public var tTitle:Label;
		public var tInfo:HTMLDivElement;
		public var img:Image;
		public var tTime:Label;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("country/order_tips");

		}

	}
}