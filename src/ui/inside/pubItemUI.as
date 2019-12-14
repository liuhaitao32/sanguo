/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.btn_icon_txt_sureUI;

	public class pubItemUI extends ItemBase {
		public var bgImg:Image;
		public var img2:Image;
		public var img1:Image;
		public var btnBuy:btn_icon_txt_sureUI;
		public var imgBG0:Image;
		public var text4:Label;
		public var text1:Label;
		public var text2:Label;
		public var text5:Label;
		public var text3:Label;
		public var imgBuy:Image;
		public var txt_check:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("inside/pubItem");

		}

	}
}