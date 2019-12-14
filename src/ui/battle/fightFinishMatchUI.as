/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightFinishMatchUI extends ViewPanel {
		public var panel:Box;
		public var bgImg:Image;
		public var imgWin:Image;
		public var bar0:ProgressBar;
		public var bar1:ProgressBar;
		public var name0:Label;
		public var name1:Label;
		public var win0:Label;
		public var win1:Label;
		public var hp0:Label;
		public var hp1:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightFinishMatch");

		}

	}
}