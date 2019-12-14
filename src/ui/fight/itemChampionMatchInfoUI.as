/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.hero_power2UI;
	import ui.com.hero_power3UI;

	public class itemChampionMatchInfoUI extends ItemBase {
		public var win0:Image;
		public var win1:Image;
		public var heroIcon0:hero_icon1UI;
		public var heroIcon1:hero_icon1UI;
		public var btn:Button;
		public var tName0:Label;
		public var tName1:Label;
		public var tOver:Label;
		public var comPower0:hero_power2UI;
		public var comPower1:hero_power3UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			View.regComponent("ui.com.hero_power3UI",hero_power3UI);
			super.createChildren();
			loadUI("fight/itemChampionMatchInfo");

		}

	}
}