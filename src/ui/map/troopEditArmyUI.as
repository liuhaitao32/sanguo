/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.army_icon2UI;

	public class troopEditArmyUI extends ItemBase {
		public var img:Image;
		public var bar:ProgressBar;
		public var tName:Label;
		public var tArmy:Label;
		public var tBar:Label;
		public var kucun:Label;
		public var tLv:Label;
		public var army_type:army_icon2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.army_icon2UI",army_icon2UI);
			super.createChildren();
			loadUI("map/troopEditArmy");

		}

	}
}