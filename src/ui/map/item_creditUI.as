/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;

	public class item_creditUI extends ItemBase {
		public var imgIcon:Image;
		public var imgBg:Panel;
		public var imgCircle:Image;
		public var comPay:payTypeUI;
		public var numLabel:Label;
		public var imgGet:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("map/item_credit");

		}

	}
}