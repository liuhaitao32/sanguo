/**Created by the LayaAirIDE,do not modify.*/
package ui.guide {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class guideSkipUI extends ViewPanel {
		public var box_back:Box;
		public var btn_back:Image;
		public var txt_tips_new:Label;
		public var txt_title_new:Label;
		public var box_skip:Box;
		public var btn_skip:Image;
		public var txt_tips_old:Label;
		public var txt_title_old:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("guide/guideSkip");

		}

	}
}