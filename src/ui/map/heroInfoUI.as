/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.item_titleUI;
	import ui.com.hero_icon1UI;
	import ui.com.hero_starUI;
	import ui.com.img_c_txt_cUI;
	import ui.com.army_icon2UI;
	import ui.com.hero_power2UI;
	import ui.com.hero_lv2UI;
	import ui.hero.heroEquipItemUI;
	import ui.com.skillItemUI;

	public class heroInfoUI extends ViewPanel {
		public var all:Box;
		public var imgBG:Image;
		public var comTitle:item_titleUI;
		public var boxTop:Box;
		public var comHero:hero_icon1UI;
		public var comStar:hero_starUI;
		public var imgRatity:Image;
		public var labelName:Label;
		public var tGroup:Label;
		public var attr1:Label;
		public var attr2:Label;
		public var attr3:Label;
		public var attr4:Label;
		public var armyLabel0:Label;
		public var armyLabel1:Label;
		public var amryName0:Label;
		public var armyName1:Label;
		public var heroType:img_c_txt_cUI;
		public var armyIcon0:army_icon2UI;
		public var armyIcon1:army_icon2UI;
		public var comPower:hero_power2UI;
		public var heroLv:hero_lv2UI;
		public var boxEquip:Box;
		public var equip0:heroEquipItemUI;
		public var equip1:heroEquipItemUI;
		public var equip2:heroEquipItemUI;
		public var equip3:heroEquipItemUI;
		public var equip4:heroEquipItemUI;
		public var boxList:Box;
		public var list:List;
		public var boxAwaken:Box;
		public var tAwaken:Label;
		public var boxAwakenInfo:Box;
		public var boxBeast:Box;
		public var beastTxt0:Label;
		public var beastImg0:Image;
		public var beastTxt1:Label;
		public var beastImg1:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			View.regComponent("ui.com.img_c_txt_cUI",img_c_txt_cUI);
			View.regComponent("ui.com.army_icon2UI",army_icon2UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_lv2UI",hero_lv2UI);
			View.regComponent("ui.hero.heroEquipItemUI",heroEquipItemUI);
			View.regComponent("ui.com.skillItemUI",skillItemUI);
			super.createChildren();
			loadUI("map/heroInfo");

		}

	}
}