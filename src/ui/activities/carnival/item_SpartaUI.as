/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class item_SpartaUI extends ItemBase {
		public var heroCom:hero_icon2UI;
		public var infoLabel:Label;
		public var titleLabel:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("activities/carnival/item_Sparta");

		}

	}
}