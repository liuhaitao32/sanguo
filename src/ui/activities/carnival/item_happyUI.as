/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class item_happyUI extends ItemBase {
		public var img0:Image;
		public var img1:Image;
		public var dayLabel:Label;
		public var btnGet:Button;
		public var imgGet:Image;
		public var rewardList:List;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("activities/carnival/item_happy");

		}

	}
}