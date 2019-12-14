/**Created by the LayaAirIDE,do not modify.*/
package ui.task {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;
	import ui.bag.bagItemUI;

	public class item_workUI extends ItemBase {
		public var isSub:Image;
		public var isGet:Image;
		public var tName:Label;
		public var tInfo:Label;
		public var mSelect:Image;
		public var award_other:payTypeUI;
		public var award_merit:payTypeUI;
		public var iTitle:Label;
		public var cCom:bagItemUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("task/item_work");

		}

	}
}