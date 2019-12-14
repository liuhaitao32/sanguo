/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class MarchInfoUI extends ItemBase {
		public var time_pro:ProgressBar;
		public var countDown_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/MarchInfo");

		}

	}
}