/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class title_hero_sUI extends ComPayType {
		public var lv1:Image;
		public var lv2:Image;
		public var lv3:Image;
		public var lv4:Image;
		public var tName:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/title_hero_s");

		}

	}
}