/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.hero_icon2UI;
	import ui.com.payTypeSUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class freeBuyUI extends ViewPanel {
		public var back0:Image;
		public var back1:Image;
		public var comHero:hero_icon2UI;
		public var btn:Button;
		public var infoLabel:Label;
		public var text0:Label;
		public var compay0:payTypeSUI;
		public var box_baggage:Box;
		public var label0:Label;
		public var label1:Label;
		public var label2:Label;
		public var label3:Label;
		public var label4:Label;
		public var img0:Image;
		public var box_gtask:Box;
		public var box_time:Box;
		public var text3:Label;
		public var timeLabel:Label;
		public var box_weapon:Box;
		public var rList:List;
		public var text1:Label;
		public var box_box:Box;
		public var compay1:payTypeSUI;
		public var tab:Tab;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("init/freeBuy");

		}

	}
}