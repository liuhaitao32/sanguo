/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightBeastSkillUI extends ItemBase {
		public var image:Image;
		public var icon:Image;
		public var title:Label;
		public var extra:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightBeastSkill");

		}

	}
}