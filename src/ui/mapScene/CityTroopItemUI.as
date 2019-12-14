/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class CityTroopItemUI extends ItemBase {
		public var heroIcon:hero_icon1UI;
		public var value_pro:ProgressBar;
		public var icon_img:Image;
		public var state_txt:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("mapScene/CityTroopItem");

		}

	}
}