/**Created by the LayaAirIDE,do not modify.*/
package ui {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.display.Text;

	public class lanzhuanguizuUI extends ViewScenes {
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("Text",Text);
			super.createChildren();
			loadUI("lanzhuanguizu");

		}

	}
}