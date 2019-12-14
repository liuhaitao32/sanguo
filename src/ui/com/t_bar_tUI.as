/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class t_bar_tUI extends ComPayType {
		public var tVar:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/t_bar_t");

		}

	}
}