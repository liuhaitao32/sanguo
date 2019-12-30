/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class honourInfoUI extends ViewPanel {
		public var tTitle:Label;
		public var text1:Label;
		public var tTips:Label;
		public var text2:Label;
		public var text0:Label;
		public var tPro:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("honour/honourInfo");

		}

	}
}