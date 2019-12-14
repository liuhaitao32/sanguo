/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import laya.html.dom.HTMLDivElement;

	public class equip_make_infoUI extends ViewPanel {
		public var boxBg:Box;
		public var iconBox:Box;
		public var tName:Label;
		public var tType:Label;
		public var tHero:Label;
		public var icon:bagItemUI;
		public var mBoxAttr:Image;
		public var washInfo:HTMLDivElement;
		public var washBox:Box;
		public var tWash:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("inside/equip_make_info");

		}

	}
}