/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.rank_inder_img_t_bigUI;

	public class guildMemberItemUI extends ItemBase {
		public var itemBG:Image;
		public var imgJob:Image;
		public var imgCity:Image;
		public var nameLabel:Label;
		public var onLineLabel:Label;
		public var lvLabel:Label;
		public var btnSet:Button;
		public var jobLabel:Label;
		public var typeLabel:Label;
		public var comIndex:rank_inder_img_t_bigUI;
		public var comApply:Box;
		public var btn:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			super.createChildren();
			loadUI("guild/guildMemberItem");

		}

	}
}