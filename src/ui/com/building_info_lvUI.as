/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class building_info_lvUI extends ComPayType {
		public var bIcon:Box;
		public var imgName:Image;
		public var tbName:Label;
		public var tbLvNext:Label;
		public var tbLv:Label;
		public var txt_hint_lv:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/building_info_lv");

		}

	}
}