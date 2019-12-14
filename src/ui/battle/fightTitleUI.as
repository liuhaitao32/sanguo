/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightTitleUI extends ItemBase {
		public var bg:Image;
		public var titleImg:Image;
		public var titleLabel:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightTitle");

		}

	}
}