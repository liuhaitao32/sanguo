/**Created by the LayaAirIDE,do not modify.*/
package ui.beast {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.beast.ItemBeastPro2UI;

	public class beastPropertyUI extends ViewPanel {
		public var allBox:Box;
		public var comTitle:item_titleUI;
		public var imgBG:Image;
		public var img0:Image;
		public var text0:Label;
		public var com1:ItemBeastPro2UI;
		public var com2:ItemBeastPro2UI;
		public var pPanel:Panel;
		public var tLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.beast.ItemBeastPro2UI",ItemBeastPro2UI);
			super.createChildren();
			loadUI("beast/beastProperty");

		}

	}
}