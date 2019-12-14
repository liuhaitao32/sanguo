/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.equipBox {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn1UI;
	import ui.com.item_title1UI;
	import ui.com.payTypeUI;
	import ui.com.btn_icon_txt_sureUI;

	public class equipBoxUI extends ViewPanel {
		public var comTitle:item_title1UI;
		public var aniBack:Panel;
		public var timeBox:Box;
		public var timeImg:Image;
		public var text0:Label;
		public var tTime:Label;
		public var comNum:payTypeUI;
		public var text1:Label;
		public var tLimit:Label;
		public var btnCheck:Button;
		public var btnShop:Button;
		public var btnReCylce:Button;
		public var btn0:btn_icon_txt_sureUI;
		public var tInfo0:Label;
		public var btn1:btn_icon_txt_sureUI;
		public var tInfo1:Label;
		public var btnEquip:Button;
		public var aniBox:Box;
		public var partBox:Panel;
		public var mBtn:Button;
		public var comBox:Box;
		public var glowBox:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn1UI",panel_bg_btn1UI);
			View.regComponent("ui.com.item_title1UI",item_title1UI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("activities/equipBox/equipBox");

		}

	}
}