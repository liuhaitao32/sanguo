/**Created by the LayaAirIDE,do not modify.*/
package ui.arena {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.btn_gotoUI;
	import ui.com.payTypeUI;

	public class arenaMainUI extends ViewScenes {
		public var shopBtn:btn_gotoUI;
		public var text0:Label;
		public var logBtn:Button;
		public var text2:Label;
		public var imgTextBg:Image;
		public var tCount:Label;
		public var askBtn:Button;
		public var comItem:payTypeUI;
		public var comBox:Box;
		public var imgBlack:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.btn_gotoUI",btn_gotoUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("arena/arenaMain");

		}

	}
}