/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.btn_icon_txt_0UI;

	public class comChat2UI extends ItemBase {
		public var boxBtm:Box;
		public var tInput:TextInput;
		public var btnChange:Button;
		public var imgCheck:Image;
		public var btnCheck:Button;
		public var btnBlack:Button;
		public var btnSend:btn_icon_txt_sureUI;
		public var chatPanel:Panel;
		public var chatContent:Box;
		public var imgArrow:Image;
		public var btnBG:Button;
		public var boxSet:Box;
		public var btnSet0:btn_icon_txt_0UI;
		public var btnSet1:btn_icon_txt_0UI;
		public var btnSet2:btn_icon_txt_0UI;
		public var btnSet3:btn_icon_txt_0UI;
		public var boxChannel:Box;
		public var btnChannel0:Button;
		public var btnChannel1:Button;
		public var btnChannel2:Button;
		public var channelInfo0:Label;
		public var channelInfo1:Label;
		public var channelInfo2:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.btn_icon_txt_0UI",btn_icon_txt_0UI);
			super.createChildren();
			loadUI("menu/comChat2");

		}

	}
}