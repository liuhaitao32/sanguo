/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemTimerUI extends ItemBase {
		public var titleImg:Image;
		public var titleLabel:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/itemTimer");

		}

	}
}