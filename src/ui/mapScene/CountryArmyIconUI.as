/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class CountryArmyIconUI extends View {
		public var icon:Image;
		public var info_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/CountryArmyIcon");

		}

	}
}