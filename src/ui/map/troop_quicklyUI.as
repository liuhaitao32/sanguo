/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.payTypeSUI;
	import ui.com.item_titleUI;

	public class troop_quicklyUI extends ViewPanel {
		public var mBox:Box;
		public var img1:Image;
		public var imgText:Image;
		public var bar_time:ProgressBar;
		public var ttime:Label;
		public var tText2:Label;
		public var tText1:Label;
		public var icon1:Image;
		public var num1:payTypeSUI;
		public var btn1:Button;
		public var icon2:Image;
		public var num2:payTypeSUI;
		public var btn2:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/troop_quickly");

		}

	}
}