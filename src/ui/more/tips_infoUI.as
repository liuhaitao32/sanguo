/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class tips_infoUI extends ViewPanel {
		public var box:Box;
		public var tInfo:HTMLDivElement;
		public var tTitle:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("more/tips_info");

		}

	}
}