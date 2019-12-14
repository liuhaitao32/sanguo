/**Created by the LayaAirIDE,do not modify.*/
package ui.mail {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.mail.chatItemUI;
	import ui.com.item_titleUI;

	public class mailPersonalUI extends ViewPanel {
		public var list:List;
		public var inputLabel:TextInput;
		public var sendBtn:Button;
		public var comTitle:item_titleUI;
		public var panel:Panel;
		public var vb:VBox;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.mail.chatItemUI",chatItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("mail/mailPersonal");

		}

	}
}