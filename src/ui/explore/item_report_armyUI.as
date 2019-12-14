/**Created by the LayaAirIDE,do not modify.*/
package ui.explore {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;
	import ui.com.hero_icon1UI;

	public class item_report_armyUI extends ItemBase {
		public var txt_name:Label;
		public var icon_country:country_flag1UI;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("explore/item_report_army");

		}

	}
}