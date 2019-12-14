/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.img_c_txt_bUI;
	import ui.com.t_bar_tUI;
	import ui.com.item_talentUI;
	import ui.com.item_awakenUI;
	import ui.com.hero_power1UI;
	import ui.hero.btnFormationUI;
	import ui.hero.btnBeastUI;

	public class heroFeaturesUI extends ViewScenes {
		public var mFuncImg:Box;
		public var imgSuper:Image;
		public var heroIconBg:Image;
		public var imgAwaken:Image;
		public var heroIcon:hero_icon2UI;
		public var imgRarity:Image;
		public var tName:Label;
		public var heroType:img_c_txt_bUI;
		public var box_prop:Box;
		public var heroStr:t_bar_tUI;
		public var heroInt:t_bar_tUI;
		public var heroCha:t_bar_tUI;
		public var heroLead:t_bar_tUI;
		public var btn_next:Button;
		public var btn_pre:Button;
		public var clipTitle:Box;
		public var btn_title:Image;
		public var tTitle:Label;
		public var comTalent:item_talentUI;
		public var comAwaken:item_awakenUI;
		public var comPower:hero_power1UI;
		public var btn_formation:btnFormationUI;
		public var box_hint:Box;
		public var btn_beast:btnBeastUI;
		public var mFunc:Box;
		public var tab:Tab;
		public var mPanel:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.img_c_txt_bUI",img_c_txt_bUI);
			View.regComponent("ui.com.t_bar_tUI",t_bar_tUI);
			View.regComponent("ui.com.item_talentUI",item_talentUI);
			View.regComponent("ui.com.item_awakenUI",item_awakenUI);
			View.regComponent("ui.com.hero_power1UI",hero_power1UI);
			View.regComponent("ui.hero.btnFormationUI",btnFormationUI);
			View.regComponent("ui.hero.btnBeastUI",btnBeastUI);
			super.createChildren();
			loadUI("hero/heroFeatures");

		}

	}
}