/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.treasure {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class item_treasureUI extends ItemBase {
		public var boxAdd:Box;
		public var imgKuang:Image;
		public var addImg:Image;
		public var com:bagItemUI;
		public var img:Image;
		public var select:Image;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/treasure/item_treasure");

		}

	}
}