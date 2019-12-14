/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.hero_icon2UI;
	import ui.com.hero_starUI;
	import ui.com.hero_power2UI;
	import ui.com.hero_lv1UI;
	import ui.bag.bagItemUI;
	import ui.com.img_c_txt_bUI;
	import ui.com.item_titleUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.btn_icon_txtUI;

	public class heroCatchUI extends ViewPanel {
		public var comHero:hero_icon2UI;
		public var imgRatity:Image;
		public var comStar:hero_starUI;
		public var comPower:hero_power2UI;
		public var heroLv:hero_lv1UI;
		public var nameLabel:Label;
		public var text1:Label;
		public var text0:Label;
		public var labelInfo:Label;
		public var list:List;
		public var heroType:img_c_txt_bUI;
		public var btn:Button;
		public var comTitle:item_titleUI;
		public var box1:Box;
		public var btnCatch:btn_icon_txt_sureUI;
		public var btnAdd:Button;
		public var labelCount:Label;
		public var box0:Box;
		public var btnRefresh:btn_icon_txtUI;
		public var btnUnlock:Button;
		public var labelTime:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_lv1UI",hero_lv1UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.img_c_txt_bUI",img_c_txt_bUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			super.createChildren();
			loadUI("map/heroCatch");

		}

	}
}