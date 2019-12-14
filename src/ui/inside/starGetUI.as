/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.payTypeUI;
	import ui.com.item_titleUI;

	public class starGetUI extends ViewPanel {
		public var box:Box;
		public var img:Image;
		public var btnOne:btn_icon_txt_sureUI;
		public var com0:payTypeUI;
		public var textLabel00:Label;
		public var textLabel0:Label;
		public var btnTen:btn_icon_txt_sureUI;
		public var com1:payTypeUI;
		public var textLabel11:Label;
		public var textLabel1:Label;
		public var btnCheck:Button;
		public var btnInfo:Button;
		public var boxText:Box;
		public var img0:Image;
		public var text1:Label;
		public var text2:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/starGet");

		}

	}
}