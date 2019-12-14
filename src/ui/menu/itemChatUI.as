/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;
	import laya.html.dom.HTMLDivElement;

	public class itemChatUI extends ItemBase {
		public var chat_country:country_flag1UI;
		public var chat_name:Label;
		public var chat_btn:Button;
		public var chat_pan:Panel;
		public var chat_info:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("menu/itemChat");

		}

	}
}