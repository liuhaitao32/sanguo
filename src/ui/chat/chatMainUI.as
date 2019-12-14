/**Created by the LayaAirIDE,do not modify.*/
package ui.chat {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.chat.item_chat_userUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.btn_icon_txt_0UI;
	import laya.html.dom.HTMLDivElement;

	public class chatMainUI extends ViewScenes {
		public var list:List;
		public var inputLabel:TextInput;
		public var btnSend:btn_icon_txt_sureUI;
		public var btnChange:Button;
		public var imgCheck:Image;
		public var btnFace:Button;
		public var btnCheck:Button;
		public var btnBlack:Button;
		public var btnBG:Button;
		public var boxSet:Box;
		public var btnSet0:btn_icon_txt_0UI;
		public var btnSet1:btn_icon_txt_0UI;
		public var btnSet2:btn_icon_txt_0UI;
		public var btnSet3:btn_icon_txt_0UI;
		public var boxChannel:Box;
		public var imgChannel:Image;
		public var btnChannel0:Button;
		public var btnChannel1:Button;
		public var btnChannel2:Button;
		public var channelInfo0:Label;
		public var channelInfo1:Label;
		public var channelInfo2:Label;
		public var btnSearch:Button;
		public var html:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("ui.chat.item_chat_userUI",item_chat_userUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.btn_icon_txt_0UI",btn_icon_txt_0UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("chat/chatMain");

		}

	}
}