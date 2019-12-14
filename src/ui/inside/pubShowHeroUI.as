/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_awardUI;
	import ui.com.btn_icon_txt_sureUI;

	public class pubShowHeroUI extends ViewScenes {
		public var list:List;
		public var btn:Button;
		public var pan:Panel;
		public var itemBox:Box;
		public var btnBuy:btn_icon_txt_sureUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_awardUI",hero_awardUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("inside/pubShowHero");

		}

	}
}