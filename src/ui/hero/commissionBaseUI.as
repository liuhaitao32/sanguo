/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.img_c_txt_bUI;
	import ui.com.hero_lv2UI;
	import ui.com.skillItemUI;
	import ui.com.hero_power2UI;

	public class commissionBaseUI extends ItemBase {
		public var heroIcon:hero_icon1UI;
		public var icon_type:img_c_txt_bUI;
		public var heroLv:hero_lv2UI;
		public var txt_name:Label;
		public var box_tips:Box;
		public var img_tips:Image;
		public var txt_tips:Label;
		public var skillName_0:skillItemUI;
		public var skillName_1:skillItemUI;
		public var comPower:hero_power2UI;
		public var img_choose:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.img_c_txt_bUI",img_c_txt_bUI);
			View.regComponent("ui.com.hero_lv2UI",hero_lv2UI);
			View.regComponent("ui.com.skillItemUI",skillItemUI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("hero/commissionBase");

		}

	}
}