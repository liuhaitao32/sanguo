/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.weekCard {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class weekCardUI extends ItemBase {
		public var bg:Image;
		public var reward:bagItemUI;
		public var btn_pay:Button;
		public var receiveTxt2:Label;
		public var receiveTxt3:Label;
		public var tipsTxt:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("activities/weekCard/weekCard");

		}

	}
}