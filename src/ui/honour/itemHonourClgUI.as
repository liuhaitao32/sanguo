/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class itemHonourClgUI extends ItemBase {
		public var tName:Label;
		public var tTime:Label;
		public var tInfo:Label;
		public var btn:Button;
		public var rewardList:List;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("honour/itemHonourClg");

		}

	}
}