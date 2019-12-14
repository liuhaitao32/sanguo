/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.com.payTypeSUI;
	import ui.com.rank_index_img_tUI;
	import ui.bag.bagItemUI;
	import ui.com.item_titleUI;

	public class creditResultUI extends ViewPanel {
		public var comHero:hero_icon2UI;
		public var com0:payTypeSUI;
		public var comIndex:rank_index_img_tUI;
		public var btn0:Button;
		public var btn1:Button;
		public var label0:Label;
		public var label1:Label;
		public var label2:Label;
		public var label3:Label;
		public var text1:Label;
		public var text2:Label;
		public var text3:Label;
		public var label4:Label;
		public var text5:Label;
		public var list:List;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			View.regComponent("ui.com.rank_index_img_tUI",rank_index_img_tUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/creditResult");

		}

	}
}