/**Created by the LayaAirIDE,do not modify.*/
package ui.mail {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.mail.mailSysItemUI;
	import ui.mail.mailItemUI;
	import ui.com.item_titleUI;

	public class MailMainUI extends ViewPanel {
		public var tab0:Tab;
		public var text0:Label;
		public var list1:List;
		public var list0:List;
		public var btn0:Button;
		public var btnRemove:Button;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.mail.mailSysItemUI",mailSysItemUI);
			View.regComponent("ui.mail.mailItemUI",mailItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("mail/MailMain");

		}

	}
}