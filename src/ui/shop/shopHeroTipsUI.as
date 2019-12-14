/**Created by the LayaAirIDE,do not modify.*/
package ui.shop {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.img_c_txt_cUI;
	import ui.com.army_icon1UI;
	import ui.com.hero_starUI;
	import ui.com.skillItemUI;

	public class shopHeroTipsUI extends ViewPanel {
		public var all:Box;
		public var viewBG:Image;
		public var boxTop:Box;
		public var rarityIcon:Image;
		public var comHero:bagItemUI;
		public var heroType:img_c_txt_cUI;
		public var armsIcon1:army_icon1UI;
		public var armsIcon2:army_icon1UI;
		public var starCom:hero_starUI;
		public var nameLabel:Label;
		public var numLabel:Label;
		public var textLabel2:Label;
		public var attr1:Label;
		public var attr2:Label;
		public var attr3:Label;
		public var attr4:Label;
		public var skillList:List;
		public var boxMid:Box;
		public var imgLine:Image;
		public var tTalent:Label;
		public var boxTalent:Box;
		public var boxInfo:Box;
		public var tInfoName:Label;
		public var tInfo:Label;
		public var boxBottom:Box;
		public var textLabel:Label;
		public var iconList:List;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.img_c_txt_cUI",img_c_txt_cUI);
			View.regComponent("ui.com.army_icon1UI",army_icon1UI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.skillItemUI",skillItemUI);
			super.createChildren();
			loadUI("shop/shopHeroTips");

		}

	}
}