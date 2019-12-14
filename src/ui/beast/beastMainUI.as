/**Created by the LayaAirIDE,do not modify.*/
package ui.beast {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.beast.itemBeastUI;
	import laya.html.dom.HTMLDivElement;

	public class beastMainUI extends ViewPanel {
		public var allBox:Box;
		public var comTitle:item_titleUI;
		public var tempImg:Image;
		public var aniBox0:Box;
		public var beastBg0:Image;
		public var beastBg1:Image;
		public var beastBg2:Image;
		public var beastBg3:Image;
		public var beastBg4:Image;
		public var beastBg5:Image;
		public var beastBg6:Image;
		public var beastBg7:Image;
		public var beastBox:Box;
		public var aniBox1:Box;
		public var btnCheck:Button;
		public var text1:Label;
		public var btnUninstall:Button;
		public var text0:Label;
		public var btnAsk:Button;
		public var imgBlack:Image;
		public var list:List;
		public var btnSort:Button;
		public var btnAll:Button;
		public var btnType:Button;
		public var btnPos:Button;
		public var btnRes1:Button;
		public var box1:Box;
		public var btnAdd:Image;
		public var tNum:Label;
		public var box2:Box;
		public var btnRes2:Button;
		public var tResNum:Label;
		public var check0:CheckBox;
		public var check1:CheckBox;
		public var tTips:Label;
		public var tHtml:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.beast.itemBeastUI",itemBeastUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("beast/beastMain");

		}

	}
}