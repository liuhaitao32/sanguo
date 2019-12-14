/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class hero_icon_rune_txtUI extends ComPayType {
		public var imgColor:Image;
		public var diff:Image;
		public var img:Image;
		public var imgSelect:Image;
		public var bgName:Image;
		public var tName:Label;
		public var addImg:Image;
		public var boxLv:Box;
		public var tLv:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/hero_icon_rune_txt");

		}

	}
}