/**Created by the LayaAirIDE,do not modify.*/
package ui.home {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class BuildInfoUI extends ItemBase {
		public var lock_img:Image;
		public var up_img:Image;
		public var name_txt:Label;
		public var level_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("home/BuildInfo");

		}

	}
}