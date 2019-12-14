/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightSpiritUI extends ItemBase {
		public var boxBg:Box;
		public var image:Image;
		public var tSpirit:Label;
		public var box:Box;
		public var boxTitle:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightSpirit");

		}

	}
}