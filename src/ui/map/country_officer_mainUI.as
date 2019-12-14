/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.map.item_country_officerUI;

	public class country_officer_mainUI extends ItemBase {
		public var adImg1:Image;
		public var adImg2:Image;
		public var minister0:item_country_officerUI;
		public var minister1:item_country_officerUI;
		public var minister2:item_country_officerUI;
		public var minister3:item_country_officerUI;
		public var minister4:item_country_officerUI;
		public var minister5:item_country_officerUI;
		public var minister6:item_country_officerUI;
		public var minister7:item_country_officerUI;
		public var minister8:item_country_officerUI;
		public var minister9:item_country_officerUI;
		public var minister10:item_country_officerUI;
		public var minister11:item_country_officerUI;
		public var minister12:item_country_officerUI;
		public var tInvade:Label;
		public var iCity:Label;
		public var tCityNum:Label;
		public var btn0:Button;
		public var btn1:Button;

		override protected function createChildren():void {
			View.regComponent("ui.map.item_country_officerUI",item_country_officerUI);
			super.createChildren();
			loadUI("map/country_officer_main");

		}

	}
}