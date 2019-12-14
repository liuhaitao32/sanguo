/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class mouse_tipsUI extends ItemBase {
		public var bgImg:Image;
		public var label:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/mouse_tips");

		}

	}
}