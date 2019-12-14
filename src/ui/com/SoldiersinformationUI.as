/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.t_img_tUI;
	import ui.com.army_icon2UI;

	public class SoldiersinformationUI extends ItemBase {
		public var imgBox:Box;
		public var tName:Label;
		public var heroArmyAtk:t_img_tUI;
		public var heroArmyDef:t_img_tUI;
		public var heroArmySpd:t_img_tUI;
		public var heroArmyHpm:t_img_tUI;
		public var mShard:Box;
		public var icon:army_icon2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.t_img_tUI",t_img_tUI);
			View.regComponent("ui.com.army_icon2UI",army_icon2UI);
			super.createChildren();
			loadUI("com/Soldiersinformation");

		}

	}
}