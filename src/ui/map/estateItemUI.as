/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.hero_power2UI;
	import ui.com.payTypeSUI;

	public class estateItemUI extends ItemBase {
		public var img:Image;
		public var btn:Button;
		public var aniPan:Panel;
		public var text1:Label;
		public var text4:Label;
		public var statusLabel:Label;
		public var text0:Label;
		public var com2:Box;
		public var com1:bagItemUI;
		public var getLabel:Label;
		public var box1:Box;
		public var text2Img:Image;
		public var text2:Label;
		public var nameLabel:Label;
		public var imgJ:Image;
		public var comPower:hero_power2UI;
		public var comCoin:Box;
		public var coinIcon:bagItemUI;
		public var coinNum:Label;
		public var box2:Box;
		public var text3Img:Image;
		public var text3:Label;
		public var com0:payTypeSUI;
		public var btnDo:Button;
		public var btnDel:Image;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			super.createChildren();
			loadUI("map/estateItem");

		}

	}
}