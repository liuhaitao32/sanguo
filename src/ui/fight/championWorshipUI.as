/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class championWorshipUI extends ItemBase {
		public var list:List;
		public var btn:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("fight/championWorship");

		}

	}
}