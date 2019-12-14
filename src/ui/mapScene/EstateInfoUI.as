/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class EstateInfoUI extends ItemBase {
		public var occupy_img:Image;
		public var level_txt:Label;
		public var name_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/EstateInfo");

		}

	}
}