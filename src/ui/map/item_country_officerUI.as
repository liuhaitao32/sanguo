/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class item_country_officerUI extends ItemBase {
		public var bg:Image;
		public var icon:hero_icon1UI;
		public var bgColor:Image;
		public var bgImg:Image;
		public var lock:Image;
		public var tOfficer:Label;
		public var tName:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("map/item_country_officer");

		}

	}
}