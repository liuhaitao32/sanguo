/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class heroSkillItemUI extends ItemBase {
		public var imgUp:Image;
		public var bar:ProgressBar;
		public var item:bagItemUI;
		public var skill:Label;
		public var tName:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("hero/heroSkillItem");

		}

	}
}