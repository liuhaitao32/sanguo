/**Created by the LayaAirIDE,do not modify.*/
package ui.activities {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class actRewardListBaseUI extends ItemBase {
		public var panel:Image;
		public var img_description:Image;
		public var btn_get:Button;
		public var alreadyGet:Image;
		public var progressMc:Box;
		public var pBar:ProgressBar;
		public var progressTxt:Label;
		public var needPayTxt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("activities/actRewardListBase");

		}

	}
}