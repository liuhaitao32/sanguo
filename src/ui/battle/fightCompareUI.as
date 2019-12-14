/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightCompareUI extends ItemBase {
		public var image:Image;
		public var tValue0:Label;
		public var tValue1:Label;
		public var tInfo:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightCompare");

		}

	}
}