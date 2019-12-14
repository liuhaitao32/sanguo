/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.memberCard {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class memberRewardBaseUI extends ItemBase {
		public var img_icon:Image;
		public var txt_name:Label;
		public var txt_num:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("activities/memberCard/memberRewardBase");

		}

	}
}