/**Created by the LayaAirIDE,do not modify.*/
package ui.explore {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.country_flag1UI;
	import ui.com.item_titleUI;
	import ui.fight.itemPKheroUI;

	public class pve_fightUI extends ViewPanel {
		public var mBox:Box;
		public var bar1:Image;
		public var bar2:Image;
		public var btn_fight:Button;
		public var name_mine:Label;
		public var name_enemy:Label;
		public var box_pray_mine:Box;
		public var txt_mine_name_magic:Label;
		public var txt_mine_info_magic:Label;
		public var icon_mine:country_flag1UI;
		public var icon_enemy:country_flag1UI;
		public var comTitle:item_titleUI;
		public var list_mine:List;
		public var list_enemy:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.fight.itemPKheroUI",itemPKheroUI);
			super.createChildren();
			loadUI("explore/pve_fight");

		}

	}
}