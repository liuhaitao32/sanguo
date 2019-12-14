/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class building_info_infoUI extends ComPayType {
		public var iBg:Image;
		public var tInfo:HTMLDivElement;
		public var pBox:Box;
		public var pImg:Image;
		public var pName:Label;
		public var pNum:Label;
		public var pNumNext:Label;
		public var aBox:Box;
		public var aTips1:Label;
		public var aTips2:Label;
		public var aImg:Image;
		public var aIcon:Box;
		public var armyBox:Box;
		public var armyLv:Label;
		public var armyType:Label;
		public var text0:Label;
		public var t0:Label;
		public var t1:Label;
		public var t2:Label;
		public var ta0:Label;
		public var ta1:Label;
		public var ta2:Label;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("com/building_info_info");

		}

	}
}