/**Created by the LayaAirIDE,do not modify.*/
package ui.test {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class TestInsideUI extends ViewPanel {
		public var list:List;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("test/TestInside");

		}

	}
}