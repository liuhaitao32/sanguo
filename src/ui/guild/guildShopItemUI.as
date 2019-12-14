/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.btn_icon_txt_sureUI;

	public class guildShopItemUI extends ItemBase {
		public var com:bagItemUI;
		public var btnBuy:btn_icon_txt_sureUI;
		public var goodName:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("guild/guildShopItem");

		}

	}
}