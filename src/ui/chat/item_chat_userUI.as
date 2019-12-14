/**Created by the LayaAirIDE,do not modify.*/
package ui.chat {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.country_flag1UI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.comCountryOfficialUI;
	import ui.com.hero_lv2UI;

	public class item_chat_userUI extends ItemBase {
		public var imgText:Image;
		public var comHero:hero_icon1UI;
		public var comFlag:country_flag1UI;
		public var textLabel:HTMLDivElement;
		public var btnChannel:Button;
		public var timeLabel:Label;
		public var comOfficial:comCountryOfficialUI;
		public var heroLv:hero_lv2UI;
		public var nameLabel:Label;
		public var imgMayor:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.comCountryOfficialUI",comCountryOfficialUI);
			View.regComponent("ui.com.hero_lv2UI",hero_lv2UI);
			super.createChildren();
			loadUI("chat/item_chat_user");

		}

	}
}