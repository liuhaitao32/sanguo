/**Created by the LayaAirIDE,do not modify.*/
package ui.mail {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class chatItem1UI extends ItemBase {
		public var com0:hero_icon1UI;
		public var img0:Image;
		public var lvLabel:Label;
		public var text0:Label;
		public var tTime:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("mail/chatItem1");

		}

	}
}