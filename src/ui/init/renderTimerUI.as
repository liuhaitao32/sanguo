/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class renderTimerUI extends ItemBase {
		public var imgIcon:Image;
		public var nameLabel:Label;
		public var midLabel:Label;
		public var timeLabel:Label;
		public var rightLabel:Label;
		public var goBtn:Button;
		public var pro:ProgressBar;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/renderTimer");

		}

	}
}