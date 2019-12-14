/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class viewLoginChooseUI extends ViewPanel {
		public var btn_login:Button;
		public var btn_fast:Button;
		public var btn_reg:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/viewLoginChoose");

		}

	}
}