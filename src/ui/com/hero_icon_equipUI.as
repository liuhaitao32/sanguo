/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class hero_icon_equipUI extends ComPayType {
		public var imgType:Image;
		public var img:Image;
		public var equipType:Image;
		public var bgColor:Image;
		public var imgName:Image;
		public var label:Label;
		public var tStatus:Label;
		public var tHero:Label;
		public var imgAdd:Image;
		public var glowBox:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/hero_icon_equip");

		}

	}
}