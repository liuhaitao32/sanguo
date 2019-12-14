/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.t_bar_tUI;
	import ui.com.img_c_txt_bUI;
	import ui.com.army_icon1UI;

	public class legendBase_heroUI extends ItemBase {
		public var imgSuper:Image;
		public var heroIcon:hero_icon2UI;
		public var imgRarity:Image;
		public var box_prop:Box;
		public var heroStr:t_bar_tUI;
		public var heroInt:t_bar_tUI;
		public var heroCha:t_bar_tUI;
		public var heroLead:t_bar_tUI;
		public var txt_name:Label;
		public var heroType:img_c_txt_bUI;
		public var box_army:Box;
		public var txt_legend:Label;
		public var txt_legend_info:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.t_bar_tUI",t_bar_tUI);
			View.regComponent("ui.com.img_c_txt_bUI",img_c_txt_bUI);
			View.regComponent("ui.com.army_icon1UI",army_icon1UI);
			super.createChildren();
			loadUI("fight/legendBase_hero");

		}

	}
}