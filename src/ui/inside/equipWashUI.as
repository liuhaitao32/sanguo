/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.inside.itemWashUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.payTypeSUI;
	import ui.inside.equipItemUI;
	import ui.com.item_titleUI;

	public class equipWashUI extends ViewPanel {
		public var adImg:Image;
		public var tab:Tab;
		public var btnGiveUp:Button;
		public var btnSave:Button;
		public var list1:List;
		public var list2:List;
		public var btnTest:Button;
		public var btnWash:btn_icon_txt_sureUI;
		public var comNum:payTypeSUI;
		public var list:List;
		public var imgEquip:Image;
		public var labelEquip:Label;
		public var label0:Label;
		public var label1:Label;
		public var label2:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.inside.itemWashUI",itemWashUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			View.regComponent("ui.inside.equipItemUI",equipItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/equipWash");

		}

	}
}