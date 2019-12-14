/**Created by the LayaAirIDE,do not modify.*/
package ui.mail {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class mailContentUI extends ViewPanel {
		public var imgBg2:Image;
		public var imgBg1:Image;
		public var timeLabel:Label;
		public var list:List;
		public var getBtn:Button;
		public var comTitle:item_titleUI;
		public var pan:Panel;
		public var textLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("mail/mailContent");

		}

	}
}