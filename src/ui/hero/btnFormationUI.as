/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.hero.formationItemUI;

	public class btnFormationUI extends ItemBase {
		public var cCom:formationItemUI;
		public var tName:Label;

		override protected function createChildren():void {
			View.regComponent("ui.hero.formationItemUI",formationItemUI);
			super.createChildren();
			loadUI("hero/btnFormation");

		}

	}
}