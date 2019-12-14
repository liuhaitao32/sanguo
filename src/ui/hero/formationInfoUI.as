/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.item_titleUI;
	import ui.hero.formationItem2UI;

	public class formationInfoUI extends ViewPanel {
		public var cTitle:item_titleUI;
		public var img1:Image;
		public var img2:Image;
		public var img5:Image;
		public var img6:Image;
		public var img3:Image;
		public var img4:Image;
		public var tText:Label;
		public var com1:formationItem2UI;
		public var com4:formationItem2UI;
		public var com2:formationItem2UI;
		public var com5:formationItem2UI;
		public var com3:formationItem2UI;
		public var com6:formationItem2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.hero.formationItem2UI",formationItem2UI);
			super.createChildren();
			loadUI("hero/formationInfo");

		}

	}
}