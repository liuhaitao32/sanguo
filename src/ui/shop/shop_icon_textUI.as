/**Created by the LayaAirIDE,do not modify.*/
package ui.shop {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class shop_icon_textUI extends ItemBase {
		public var label0:Label;
		public var box1:Box;
		public var label1:Label;
		public var img0:Image;
		public var boxTime:Box;
		public var tTime:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("shop/shop_icon_text");

		}

	}
}