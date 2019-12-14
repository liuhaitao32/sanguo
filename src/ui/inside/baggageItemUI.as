/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.btn_icon_txt_sureUI;
	import ui.bag.bagItemUI;

	public class baggageItemUI extends ItemBase {
		public var imgIcon:Image;
		public var imgFree:Image;
		public var btnBuy:btn_icon_txt_sureUI;
		public var text1:Label;
		public var text2:Label;
		public var text3:Label;
		public var text4:Label;
		public var freeItem:bagItemUI;
		public var imgBG:Image;
		public var imgBao:Image;
		public var cFest:bagItemUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("inside/baggageItem");

		}

	}
}