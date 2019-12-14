/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.t_bar_tUI;
	import ui.com.army_icon1UI;
	import ui.com.item_talentUI;
	import ui.com.img_c_txt_bUI;

	public class heroGetNewUI extends ViewPanel {
		public var mFuncImg:Box;
		public var imgSuper:Image;
		public var heroIconBg:Image;
		public var heroIcon:hero_icon2UI;
		public var mInfo:Box;
		public var heroStr:t_bar_tUI;
		public var heroInt:t_bar_tUI;
		public var heroCha:t_bar_tUI;
		public var heroLead:t_bar_tUI;
		public var army0:army_icon1UI;
		public var army1:army_icon1UI;
		public var comTalent:item_talentUI;
		public var boxSkill:Box;
		public var tInfo:Label;
		public var imgRarity:Image;
		public var tName:Label;
		public var heroType:img_c_txt_bUI;
		public var guanbi:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.t_bar_tUI",t_bar_tUI);
			View.regComponent("ui.com.army_icon1UI",army_icon1UI);
			View.regComponent("ui.com.item_talentUI",item_talentUI);
			View.regComponent("ui.com.img_c_txt_bUI",img_c_txt_bUI);
			super.createChildren();
			loadUI("hero/heroGetNew");

		}

	}
}