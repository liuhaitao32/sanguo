/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class heroSkillUI extends ItemBase {
		public var tab:Tab;
		public var tSkill:Label;
		public var tSkillNext:Label;
		public var list:List;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("hero/heroSkill");

		}

	}
}