/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.hero_lv2UI;

	public class itemHeroEstateUI extends ItemBase {
		public var comHero:hero_icon1UI;
		public var heroLv:hero_lv2UI;
		public var bg1:Image;
		public var imgFinish:Image;
		public var imgSelect:Image;
		public var fateLabel:Image;
		public var btnChange:Button;
		public var btnTH:Button;
		public var nameLabel:Label;
		public var typeLabel:Label;
		public var statusLabel:Label;
		public var slvLabel:Label;
		public var atkNameLabel:Label;
		public var bg0:Image;
		public var atkLabel:Label;
		public var imgRatity:Image;
		public var timeLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.hero_lv2UI",hero_lv2UI);
			super.createChildren();
			loadUI("map/itemHeroEstate");

		}

	}
}