/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon_equipUI;

	public class equipItemUI extends ItemBase {
		public var item:hero_icon_equipUI;
		public var imgSuc:Image;
		public var select:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon_equipUI",hero_icon_equipUI);
			super.createChildren();
			loadUI("inside/equipItem");

		}

	}
}