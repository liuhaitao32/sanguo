/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.salePay {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class salePayItemUI extends ItemBase {
		public var bg:Image;
		public var text0:Label;
		public var btn1:Button;
		public var text1:Label;
		public var img:Image;
		public var imgUse:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("activities/salePay/salePayItem");

		}

	}
}