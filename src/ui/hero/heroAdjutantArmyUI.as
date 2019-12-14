/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.army_icon1UI;
	import ui.com.skillItemUI;

	public class heroAdjutantArmyUI extends ItemBase {
		public var txt_title:Label;
		public var txt_attack:Label;
		public var txt_defense:Label;
		public var txt_hero:Label;
		public var txt_score_equip:Label;
		public var txt_ratio_hero:Label;
		public var heroIcon:hero_icon1UI;
		public var typeIcon:army_icon1UI;
		public var skillName_0:skillItemUI;
		public var skillName_1:skillItemUI;
		public var imgBox:Box;
		public var img_lock:Image;
		public var img_add:Image;
		public var btn_go:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.army_icon1UI",army_icon1UI);
			View.regComponent("ui.com.skillItemUI",skillItemUI);
			super.createChildren();
			loadUI("hero/heroAdjutantArmy");

		}

	}
}