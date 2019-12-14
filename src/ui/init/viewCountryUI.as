/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.hero_icon2UI;

	public class viewCountryUI extends ViewScenes {
		public var mCountry:Box;
		public var adImg:Image;
		public var vb0:Image;
		public var vb1:Image;
		public var vb2:Image;
		public var c0:Box;
		public var btn_img0:Image;
		public var v0:Image;
		public var award0:bagItemUI;
		public var c2:Box;
		public var btn_img2:Image;
		public var v2:Image;
		public var award2:bagItemUI;
		public var c1:Box;
		public var btn_img1:Image;
		public var v1:Image;
		public var award1:bagItemUI;
		public var btn_1:Image;
		public var btn_2:Image;
		public var btn_0:Image;
		public var btn_22:Image;
		public var btn_00:Image;
		public var btn_222:Image;
		public var btn_11:Image;
		public var btn_111:Image;
		public var heroIcon:hero_icon2UI;
		public var cTxt:Label;
		public var tName:TextInput;
		public var btn_start:Button;
		public var btn_re:Image;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("init/viewCountry");

		}

	}
}