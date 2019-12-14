/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_awardUI;

	public class pubHeroItemUI extends ItemBase {

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_awardUI",hero_awardUI);
			super.createChildren();
			loadUI("inside/pubHeroItem");

		}

	}
}