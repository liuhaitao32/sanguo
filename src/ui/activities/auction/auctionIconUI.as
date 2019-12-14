/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.auction {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class auctionIconUI extends ItemBase {
		public var icon:hero_icon1UI;
		public var txt_name:Label;
		public var txt_state:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("activities/auction/auctionIcon");

		}

	}
}