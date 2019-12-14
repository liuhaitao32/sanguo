/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.btn_icon_txt_sureUI;

	public class creatGuildUI extends ViewPanel {
		public var putText:TextInput;
		public var btnClick:btn_icon_txt_sureUI;
		public var text0:Label;
		public var titleLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("guild/creatGuild");

		}

	}
}