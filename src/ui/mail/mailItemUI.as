/**Created by the LayaAirIDE,do not modify.*/
package ui.mail {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.country_flag1UI;

	public class mailItemUI extends ItemBase {
		public var comHead:hero_icon1UI;
		public var nameLabel:Label;
		public var guildLabel:Label;
		public var infoLabel:Label;
		public var lvLabel:Label;
		public var btn0:Button;
		public var btn1:Button;
		public var comFlag:country_flag1UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("mail/mailItem");

		}

	}
}