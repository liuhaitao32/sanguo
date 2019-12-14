/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class viewCodeUI extends ViewPanel {
		public var inputLabel:TextInput;
		public var okBtn:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/viewCode");

		}

	}
}