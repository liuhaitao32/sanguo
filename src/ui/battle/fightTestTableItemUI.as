/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_power5UI;

	public class fightTestTableItemUI extends ItemBase {
		public var tUserName:Label;
		public var tHeroName:Label;
		public var uiPower:hero_power5UI;
		public var imgChoose:Image;
		public var checkBoxOpen:CheckBox;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_power5UI",hero_power5UI);
			super.createChildren();
			loadUI("battle/fightTestTableItem");

		}

	}
}