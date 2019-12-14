/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class effect_pk_rank_changeUI extends ComPayType {
		public var box:Box;
		public var adImg:Image;
		public var tPre:Label;
		public var tNext:Label;
		public var tArmy:Label;
		public var box_award:Box;
		public var text0:Label;
		public var tAward:Label;
		public var tBg:Image;
		public var tTitle:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/effect_pk_rank_change");

		}

	}
}