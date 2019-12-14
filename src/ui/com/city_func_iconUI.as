/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class city_func_iconUI extends ComPayType {
		public var func1:Button;
		public var func2:Button;
		public var func:Box;
		public var tFunc:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/city_func_icon");

		}

	}
}