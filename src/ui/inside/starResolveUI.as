/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.inside.starResolveItemUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class starResolveUI extends ViewPanel {
		public var adImg:Image;
		public var bg0:Image;
		public var bg1:Image;
		public var btnAsk:Button;
		public var btnResolve:Button;
		public var btnMore:Button;
		public var btnQuick:Button;
		public var list1:List;
		public var list2:List;
		public var iconImg:Image;
		public var text1:Label;
		public var nameLabel:Label;
		public var text0:Label;
		public var ttab:Tab;
		public var boxNum:Box;
		public var numLabel:Label;
		public var text2:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.inside.starResolveItemUI",starResolveItemUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/starResolve");

		}

	}
}