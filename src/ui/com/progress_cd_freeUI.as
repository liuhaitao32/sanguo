/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class progress_cd_freeUI extends ItemBase {
		public var bgbg:Image;
		public var bg:Image;
		public var ok:Image;
		public var free:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/progress_cd_free");

		}

	}
}