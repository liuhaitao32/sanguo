/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class country_mainUI extends ViewScenes {
		public var tab:Tab;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/country_main");

		}

	}
}