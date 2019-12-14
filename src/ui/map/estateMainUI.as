/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.map.estateItemUI;
	import ui.com.payTypeSUI;

	public class estateMainUI extends ViewPanel {
		public var titleBg:Image;
		public var btnCheck:Button;
		public var txtBg:Image;
		public var text0Img:Image;
		public var tab:Tab;
		public var list:List;
		public var testBtn:Button;
		public var testLabel:Label;
		public var text0:Label;
		public var com0:payTypeSUI;
		public var com1:payTypeSUI;
		public var com2:payTypeSUI;
		public var com3:payTypeSUI;
		public var checkName:Label;
		public var checkLv:Label;
		public var boxMid:Box;
		public var textMid:Label;
		public var titleBox:Box;
		public var titleImg:Image;
		public var titlelabel:Label;
		public var numLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.map.estateItemUI",estateItemUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			super.createChildren();
			loadUI("map/estateMain");

		}

	}
}