/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.honour.honourLvUI;

	public class heroHonourUI extends ItemBase {

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.honour.honourLvUI",honourLvUI);
			super.createChildren();
			loadUI("honour/heroHonour");

		}

	}
}