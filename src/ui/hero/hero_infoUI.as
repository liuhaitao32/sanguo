/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class hero_infoUI extends ViewPanel {
		public var mBox:Box;
		public var tInfo:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("hero/hero_info");

		}

	}
}