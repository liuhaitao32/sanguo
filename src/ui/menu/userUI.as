/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;
	import ui.com.hero_power2UI;
	import ui.com.hero_icon1UI;
	import sg.view.menu.RightButtonBox;
	import ui.honour.btnHonourUI;

	public class userUI extends ItemBase {
		public var boxTop:Box;
		public var tName:Label;
		public var btn_estate:Button;
		public var testate:Label;
		public var imgCoin0:Image;
		public var imgCoin:Image;
		public var b1:Button;
		public var country:country_flag1UI;
		public var tOffice:Label;
		public var power:Button;
		public var comPower:hero_power2UI;
		public var boxMap:Box;
		public var boxHead:Box;
		public var heroIcon:hero_icon1UI;
		public var tLv:Label;
		public var boxRight:Box;
		public var btn_credit:Button;
		public var BoxAin:Box;
		public var creditPan:Panel;
		public var iCredit:Label;
		public var tCredit:Label;
		public var btn_log:Button;
		public var btnNpcInfo:Button;
		public var boxOrder:Box;
		public var v_box:RightButtonBox;
		public var btn_zong:Button;
		public var iZong:Label;
		public var btnNewTask:Button;
		public var btnHonour:btnHonourUI;
		public var btnCountry:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("sg.view.menu.RightButtonBox",RightButtonBox);
			View.regComponent("ui.honour.btnHonourUI",btnHonourUI);
			super.createChildren();
			loadUI("menu/user");

		}

	}
}