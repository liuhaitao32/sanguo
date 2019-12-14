/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class heroRuneItemUI extends ItemBase {
		public var runeIcon:bagItemUI;
		public var imgCurr:Image;
		public var boxLv:Box;
		public var tLv:Label;
		public var imgSelect:Image;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("hero/heroRuneItem");

		}

	}
}