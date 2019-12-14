/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class FtaskInfoUI extends ItemBase {
		public var bg_img:Image;
		public var name_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/FtaskInfo");

		}

	}
}