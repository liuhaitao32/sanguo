/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class legendMainUI extends ViewScenes {
		public var list:List;
		public var btn_add:Button;
		public var txt_num:Label;
		public var txt_hint:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("fight/legendMain");

		}

	}
}