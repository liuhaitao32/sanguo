/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon0UI;

	public class itemFateUI extends ItemBase {
		public var heroIcon:hero_icon0UI;
		public var imgSelect:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon0UI",hero_icon0UI);
			super.createChildren();
			loadUI("hero/itemFate");

		}

	}
}