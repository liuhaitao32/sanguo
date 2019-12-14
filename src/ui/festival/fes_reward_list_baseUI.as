/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fes_reward_list_baseUI extends ItemBase {
		public var panel:Image;
		public var img_description:Image;
		public var needPayTxt:Label;
		public var btn_get:Button;
		public var progressMc:Box;
		public var pBar:ProgressBar;
		public var progressTxt:Label;
		public var alreadyGet:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("festival/fes_reward_list_base");

		}

	}
}