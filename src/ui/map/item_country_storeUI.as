/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_country_storeUI extends ItemBase {
		public var tNum:Label;
		public var tInfo:Label;
		public var btn:Button;
		public var tTimes:Label;
		public var tTimesHint:Label;
		public var tTips:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/item_country_store");

		}

	}
}