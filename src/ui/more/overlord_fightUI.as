/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.more.item_overlordUI;
	import laya.html.dom.HTMLDivElement;

	public class overlord_fightUI extends ViewPanel {
		public var adImg:Image;
		public var list:List;
		public var btn:Button;
		public var boxInfo:Image;
		public var panelTxt:Panel;
		public var tInfo:HTMLDivElement;
		public var tTitle:Label;
		public var box_hint1:Box;
		public var txt_hint:Label;
		public var box_hint0:Box;
		public var iTime:Label;
		public var box_country:Box;
		public var imgFlag:Image;
		public var text0:Label;
		public var time0:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.more.item_overlordUI",item_overlordUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("more/overlord_fight");

		}

	}
}