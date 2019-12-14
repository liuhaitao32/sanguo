/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class noticePictureUI extends ViewPanel {
		public var allBox:Box;
		public var img:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/noticePicture");

		}

	}
}