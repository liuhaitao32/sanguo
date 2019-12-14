/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.inside.baggageItemUI;

	public class baggageMainUI extends ViewScenes {
		public var imgBG:Image;
		public var list:List;
		public var nextTime:Label;

		override protected function createChildren():void {
			View.regComponent("ui.inside.baggageItemUI",baggageItemUI);
			super.createChildren();
			loadUI("inside/baggageMain");

		}

	}
}