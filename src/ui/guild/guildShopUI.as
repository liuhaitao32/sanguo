/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.guild.guildShopItemUI;
	import ui.com.payTypeUI;
	import ui.com.btn_icon_txt_sureUI;

	public class guildShopUI extends ViewScenes {
		public var itemList:List;
		public var text1:Label;
		public var costCom:Box;
		public var btnAdd:Button;
		public var comNum:payTypeUI;
		public var refreshCom:Box;
		public var text2:Label;
		public var timerText:Label;
		public var btnRefresh:btn_icon_txt_sureUI;

		override protected function createChildren():void {
			View.regComponent("ui.guild.guildShopItemUI",guildShopItemUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("guild/guildShop");

		}

	}
}