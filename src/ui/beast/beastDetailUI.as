/**Created by the LayaAirIDE,do not modify.*/
package ui.beast {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import laya.html.dom.HTMLDivElement;
	import ui.beast.ItemBeastPro2UI;
	import ui.com.payTypeBigUI;

	public class beastDetailUI extends ViewPanel {
		public var comTitle:item_titleUI;
		public var iconBg:Image;
		public var btnLock:Button;
		public var tLv1:Label;
		public var tName:Label;
		public var tLv:Label;
		public var tHtml:HTMLDivElement;
		public var tHtml1:HTMLDivElement;
		public var tHtml2:HTMLDivElement;
		public var tHtml3:HTMLDivElement;
		public var com0:ItemBeastPro2UI;
		public var com1:ItemBeastPro2UI;
		public var lvSlider:HSlider;
		public var btn1:Button;
		public var btn0:Button;
		public var btn2:Button;
		public var text1:Label;
		public var comPay0:payTypeBigUI;
		public var comPay1:payTypeBigUI;
		public var comPay2:payTypeBigUI;
		public var btnRes:Button;
		public var btnInstall:Button;
		public var addNum:Label;
		public var tAdd:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.beast.ItemBeastPro2UI",ItemBeastPro2UI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("beast/beastDetail");

		}

	}
}