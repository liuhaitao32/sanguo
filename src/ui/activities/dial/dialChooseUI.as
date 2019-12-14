/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.dial {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn1UI;
	import ui.com.item_title1UI;
	import ui.bag.bagItemUI;
	import ui.activities.treasure.item_treasureUI;

	public class dialChooseUI extends ViewPanel {
		public var comTitle:item_title1UI;
		public var list1:List;
		public var list2:List;
		public var btn:Button;
		public var btn0:Button;
		public var btn1:Button;
		public var btn2:Button;
		public var getBox:Box;
		public var text0:Label;
		public var getImg:Image;
		public var getLabel:Label;
		public var infoLabel:Label;
		public var numLabel:Label;
		public var text1:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn1UI",panel_bg_btn1UI);
			View.regComponent("ui.com.item_title1UI",item_title1UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.activities.treasure.item_treasureUI",item_treasureUI);
			super.createChildren();
			loadUI("activities/dial/dialChoose");

		}

	}
}