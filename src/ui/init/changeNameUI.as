/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class changeNameUI extends ViewPanel {
		public var tName:TextInput;
		public var bImg:Image;
		public var btn:Button;
		public var comProp:bagItemUI;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("init/changeName");

		}

	}
}