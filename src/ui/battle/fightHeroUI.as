/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class fightHeroUI extends ItemBase {
		public var boxL:Box;
		public var heroIcon0:hero_icon1UI;
		public var lv0:Label;
		public var t_str0:Label;
		public var t_agi0:Label;
		public var t_cha0:Label;
		public var t_lead0:Label;
		public var str0:Label;
		public var agi0:Label;
		public var cha0:Label;
		public var lead0:Label;
		public var name0:Label;
		public var boxR:Box;
		public var heroIcon1:hero_icon1UI;
		public var lv1:Label;
		public var t_str1:Label;
		public var t_agi1:Label;
		public var t_cha1:Label;
		public var t_lead1:Label;
		public var str1:Label;
		public var agi1:Label;
		public var cha1:Label;
		public var lead1:Label;
		public var name1:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("battle/fightHero");

		}

	}
}