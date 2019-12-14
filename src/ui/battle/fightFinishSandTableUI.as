/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightFinishSandTableUI extends ViewPanel {
		public var panel:Box;
		public var bgImg:Image;
		public var starBox:Box;
		public var starImg0:Image;
		public var starImg1:Image;
		public var starImg2:Image;
		public var stateBox:Box;
		public var stateImg0:Image;
		public var stateImg1:Image;
		public var stateImg2:Image;
		public var stateTxt0:Label;
		public var stateTxt1:Label;
		public var stateTxt2:Label;
		public var rewardBox:Box;
		public var rewardTxt:Label;
		public var anyTxt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightFinishSandTable");

		}

	}
}