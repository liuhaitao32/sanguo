/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;

	public class menuMainUI extends ViewScenes {
		public var mStack:ViewStack;
		public var btn_climb:Button;
		public var btn_climb1:Button;
		public var adImg0:Image;
		public var title_climb_img:Image;
		public var title_climb:Label;
		public var box_climb_times:Box;
		public var img_climb:Image;
		public var text2:Label;
		public var climb_times:Label;
		public var btn_pve:Button;
		public var btn_pve1:Button;
		public var adImg2:Image;
		public var title_pve_img:Image;
		public var title_pve:Label;
		public var box_pve_times:Box;
		public var img_pvp:Image;
		public var text3:Label;
		public var pve_times:Label;
		public var btn_pk:Button;
		public var adImg1:Image;
		public var title_pk_img:Image;
		public var title_pk:Label;
		public var box_pk_times:Box;
		public var img_pk:Image;
		public var text0:Label;
		public var pk_times:Label;
		public var btn_champion:Button;
		public var adImg3:Image;
		public var title_champion_img:Image;
		public var champion_times:Label;
		public var title_cham:Label;
		public var btn_treasureHunting:Button;
		public var adImg4:Image;
		public var title_explore_img:Image;
		public var txt_title_explore:Label;
		public var box_hunt_hint:Box;
		public var txt_hunt_hint:Label;
		public var box_hunt_times:Box;
		public var img_hunt:Image;
		public var txt_hunt_times_hint:Label;
		public var txt_hunt_times:Label;
		public var btn_legend:Button;
		public var adImg5:Image;
		public var title_lengend_img:Image;
		public var txt_title_legend:Label;
		public var box_legend_times:Box;
		public var img_legend:Image;
		public var txt_legend_times_hint:Label;
		public var txt_legend_times:Label;
		public var tab:Tab;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("fight/menuMain");

		}

	}
}