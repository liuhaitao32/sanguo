/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class introducePanelUI extends ViewPanel {
		public var box:Box;
		public var panel2:Image;
		public var lightPic:Image;
		public var panel1:Image;
		public var titleTxt:Label;
		public var introduceTxt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("more/introducePanel");

		}

	}
}