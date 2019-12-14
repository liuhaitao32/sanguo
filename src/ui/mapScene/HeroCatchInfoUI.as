/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class HeroCatchInfoUI extends ItemBase {
		public var name_txt:Label;
		public var countDown_txt:Label;
		public var text_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/HeroCatchInfo");

		}

	}
}