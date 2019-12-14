/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.title_hero_sUI;

	public class itemTitleUI extends ItemBase {
		public var select:Image;
		public var tTime:Label;
		public var titleIcon:title_hero_sUI;
		public var tStatus:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.title_hero_sUI",title_hero_sUI);
			super.createChildren();
			loadUI("hero/itemTitle");

		}

	}
}