/**Created by the LayaAirIDE,do not modify.*/
package ui.home {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class BuidingInfoUI extends ItemBase {
		public var pro:ProgressBar;
		public var pro_txt:Label;
		public var info_txt:Label;
		public var icon_img:Sprite;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("home/BuidingInfo");

		}

	}
}