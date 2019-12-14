/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_power2UI;
	import ui.com.hero_icon1UI;
	import ui.com.comCountryOfficialUI;

	public class userInfoNormalUI extends ItemBase {
		public var bName:Button;
		public var bHead:Button;
		public var comPower:hero_power2UI;
		public var cHead:hero_icon1UI;
		public var list:List;
		public var text3:Label;
		public var tLv:Label;
		public var text4:Label;
		public var tOffice:Label;
		public var text5:Label;
		public var tFarm:Label;
		public var text6:Label;
		public var tHistory:Label;
		public var tName:Label;
		public var text2:Label;
		public var imgFlag:Image;
		public var comOffcial:comCountryOfficialUI;
		public var tMayor:Label;
		public var btnChat:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.comCountryOfficialUI",comCountryOfficialUI);
			super.createChildren();
			loadUI("menu/userInfoNormal");

		}

	}
}