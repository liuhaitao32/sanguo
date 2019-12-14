/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.auction {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.hero_icon1UI;
	import ui.bag.bagItemUI;
	import ui.com.payTypeBigUI;
	import ui.com.country_flag1UI;

	public class auctionBaseUI extends ItemBase {
		public var img_frame0:Image;
		public var img_bg:Image;
		public var imgAwaken:Image;
		public var character:hero_icon2UI;
		public var img_frame1:Image;
		public var txt_hero_name:Label;
		public var txt_chip_name:Label;
		public var icon_hero:hero_icon1UI;
		public var icon_chip:bagItemUI;
		public var box_time:Box;
		public var txt_hint0:Label;
		public var txt_time:Label;
		public var img_hint0:Image;
		public var img_hint1:Image;
		public var txt_gift_name:Label;
		public var btn:Button;
		public var box_price:Box;
		public var icon_cost:payTypeBigUI;
		public var txt_hint1:Label;
		public var box_end:Box;
		public var icon_cost2:payTypeBigUI;
		public var txt_hint2:Label;
		public var txt_hint3:Label;
		public var box_owner:Box;
		public var txt_owner_hint:Label;
		public var icon_flag:country_flag1UI;
		public var txt_owner:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("activities/auction/auctionBase");

		}

	}
}