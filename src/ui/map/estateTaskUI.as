/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.payTypeSUI;
	import ui.map.itemHeroEstateUI;
	import ui.map.item_city_build_gearUI;
	import ui.com.item_titleUI;
	import ui.com.hero_icon2UI;
	import ui.com.hero_icon1UI;
	import ui.bag.bagItemUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.btn_icon_txtUI;
	import ui.com.item_estateUI;

	public class estateTaskUI extends ViewPanel {
		public var all:Box;
		public var imgBG:Image;
		public var text0:Label;
		public var text1:Label;
		public var text2:Label;
		public var text3:Label;
		public var comHeroBig:hero_icon2UI;
		public var com3:itemHeroEstateUI;
		public var buildBox:Box;
		public var text5:Label;
		public var text6:Label;
		public var buildLabel0:Label;
		public var buildLabel1:Label;
		public var buildLabel00:Label;
		public var buildLabel01:Label;
		public var boxPro:Box;
		public var pro:ProgressBar;
		public var imgMore:Image;
		public var proLabel:Label;
		public var list:List;
		public var comTitle:item_titleUI;
		public var dimBox:Box;
		public var dimLabel:Label;
		public var comGet0:item_estateUI;
		public var imgExtra:Image;
		public var comGet1:item_estateUI;
		public var comGetHero:Box;
		public var text7:Label;
		public var comGet2:hero_icon1UI;
		public var comGetCoin:item_estateUI;
		public var cFest:bagItemUI;
		public var btn0:btn_icon_txt_sureUI;
		public var btn1:btn_icon_txtUI;
		public var comCost1:Box;
		public var costLabel:Label;
		public var boxBuild:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			View.regComponent("ui.map.itemHeroEstateUI",itemHeroEstateUI);
			View.regComponent("ui.map.item_city_build_gearUI",item_city_build_gearUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.com.item_estateUI",item_estateUI);
			super.createChildren();
			loadUI("map/estateTask");

		}

	}
}