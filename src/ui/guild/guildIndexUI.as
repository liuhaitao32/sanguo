/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.btn_icon_txt_sureUI;
	import ui.guild.guildItemUI;

	public class guildIndexUI extends ViewScenes {
		public var title0:Label;
		public var title1:Label;
		public var title2:Label;
		public var title4:Label;
		public var title3:Label;
		public var putText:TextInput;
		public var btnSearch:Button;
		public var btnCreat:btn_icon_txt_sureUI;
		public var tSearch:Label;
		public var list:List;
		public var text0:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.guild.guildItemUI",guildItemUI);
			super.createChildren();
			loadUI("guild/guildIndex");

		}

	}
}