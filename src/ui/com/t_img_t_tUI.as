/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class t_img_t_tUI extends ComPayType {
		public var tTitle:Label;
		public var tC:Label;
		public var tA:Label;
		public var tB:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/t_img_t_t");

		}

	}
}