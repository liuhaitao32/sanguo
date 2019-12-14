/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.bag.bagItemUI;
	import ui.com.hero_resolveUI;
	import ui.com.btn_icon_txtUI;
	import ui.com.btn_icon_txt_sureUI;

	public class propResolveUI extends ViewScenes {
		public var heroIconBg:Image;
		public var imgSuper:Image;
		public var imgAwaken:Image;
		public var comHero:hero_icon2UI;
		public var btnCheck:Button;
		public var btnText:Button;
		public var btnX:Button;
		public var btnShop:Button;
		public var rewardList:List;
		public var heroList:List;
		public var textLabel2:Label;
		public var numLabel:Label;
		public var text0:Label;
		public var boxNum:Box;
		public var textBg1:Image;
		public var btnBlock:Button;
		public var textLabel1:Label;
		public var boxOne:Box;
		public var textLabel3:Label;
		public var btnBuy:btn_icon_txtUI;
		public var boxTen:Box;
		public var btnBuyTen:btn_icon_txt_sureUI;
		public var textLabel4:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.hero_resolveUI",hero_resolveUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			super.createChildren();
			loadUI("inside/propResolve");

		}

	}
}