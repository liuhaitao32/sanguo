/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import sg.view.com.sgCloseBtn;

	public class GoldCityPanelUI extends ViewPanel {
		public var bg_img:Image;

		override protected function createChildren():void {
			View.regComponent("sg.view.com.sgCloseBtn",sgCloseBtn);
			super.createChildren();
			loadUI("mapScene/GoldCityPanel");

		}

	}
}