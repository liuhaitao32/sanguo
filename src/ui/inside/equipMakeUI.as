/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.inside.equipItemUI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.hero_icon_equipUI;
	import ui.com.item_titleUI;

	public class equipMakeUI extends ViewPanel {
		public var adImg:Image;
		public var tab:Tab;
		public var list:List;
		public var mInfo:Box;
		public var tNoMake:HTMLDivElement;
		public var priceRuler:Label;
		public var tInfo:Label;
		public var mBoxView:Box;
		public var makeReady:hero_icon_equipUI;
		public var tReady:Label;
		public var imgName:Image;
		public var tName:Label;
		public var mBoxInfo:Box;
		public var text0:Label;
		public var tEquipInfo:Label;
		public var mBoxPro:Image;
		public var btn_change:Button;
		public var btn_make:Button;
		public var tReady2:Label;
		public var tList:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.inside.equipItemUI",equipItemUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.hero_icon_equipUI",hero_icon_equipUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/equipMake");

		}

	}
}