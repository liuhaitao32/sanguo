/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.fund {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fundBaseUI extends ComPayType {
		public var alreadyGet:Image;
		public var gold_skin:Box;
		public var btn_get:Button;
		public var dayTxt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("activities/fund/fundBase");

		}

	}
}