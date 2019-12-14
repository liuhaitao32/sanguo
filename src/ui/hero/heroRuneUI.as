/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class heroRuneUI extends ItemBase {
		public var clipBox:Box;
		public var btn_set:Button;
		public var btn_up:Button;
		public var tab:Tab;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("hero/heroRune");

		}

	}
}