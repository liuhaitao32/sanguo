/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemPKreportUI extends ItemBase {
		public var imgArrow:Image;
		public var tName0:Label;
		public var tName1:Label;
		public var tTime:Label;
		public var tResult:Label;
		public var tRank:Label;
		public var text0:Label;
		public var imgWin:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("fight/itemPKreport");

		}

	}
}