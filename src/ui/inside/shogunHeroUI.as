/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.inside.shogunHeroItemUI;
	import ui.com.item_titleUI;

	public class shogunHeroUI extends ViewPanel {
		public var list:List;
		public var text02:Label;
		public var text2:Label;
		public var joinBtn:Button;
		public var upBtn:Button;
		public var text1:Label;
		public var text01:Label;
		public var text04:Label;
		public var text4:Label;
		public var text03:Label;
		public var text3:Label;
		public var text05:Label;
		public var text5:Label;
		public var comTitle:item_titleUI;
		public var askBtn:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.inside.shogunHeroItemUI",shogunHeroItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/shogunHero");

		}

	}
}