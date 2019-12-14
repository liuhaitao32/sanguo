/**Created by the LayaAirIDE,do not modify.*/
package ui.guide {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class guideImageUI extends ViewPanel {
		public var box:Box;
		public var img:Image;
		public var words:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("guide/guideImage");

		}

	}
}