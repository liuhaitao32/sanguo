/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class bless_reward_baseUI extends ItemBase {
		public var item:bagItemUI;
		public var box_finish:Box;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("map/bless_reward_base");

		}

	}
}